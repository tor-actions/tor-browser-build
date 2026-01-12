#!/usr/bin/env python3
import argparse
from collections import namedtuple
import configparser
from datetime import datetime, timezone
from hashlib import sha256
import locale
import logging
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

from git import Repo
from git.exc import GitCommandError
import requests
import ruamel.yaml

import fetch_changelogs
from update_manual import update_manual


logger = logging.getLogger(__name__)


ReleaseTag = namedtuple("ReleaseTag", ["tag", "version"])


class Version:
    def __init__(self, v):
        self.v = v
        m = re.match(r"(\d+\.\d+)([a\.])?(\d*)", v)
        self.major = m.group(1)
        self.minor = int(m.group(3)) if m.group(3) else 0
        self.is_alpha = m.group(2) == "a"
        self.channel = "alpha" if self.is_alpha else "release"

    def __str__(self):
        return self.v

    def __lt__(self, other):
        if self.major != other.major:
            # String comparison, but it should be fine until
            # version 100 :)
            return self.major < other.major
        if self.is_alpha != other.is_alpha:
            return self.is_alpha
        # Same major, both alphas/releases
        return self.minor < other.minor

    def __eq__(self, other):
        return self.v == other.v

    def __hash__(self):
        return hash(self.v)


def get_sorted_tags(repo):
    return sorted(
        [t.tag for t in repo.tags if t.tag],
        key=lambda t: t.tagged_date,
        reverse=True,
    )


def get_github_release(project, regex=""):
    if regex:
        regex = re.compile(regex)
    url = f"https://github.com/{project}/releases.atom"
    r = requests.get(url)
    r.raise_for_status()
    feed = ET.fromstring(r.text)
    for entry in feed.findall("{http://www.w3.org/2005/Atom}entry"):
        link = entry.find("{http://www.w3.org/2005/Atom}link").attrib["href"]
        tag = link.split("/")[-1]
        if regex:
            m = regex.match(tag)
            if m:
                return m.group(1)
        else:
            return tag
    raise RuntimeError(
        f"Could find a release for {project} that matches the regex."
    )


class ReleasePreparation:
    def __init__(self, repo_path, version, **kwargs):
        logger.debug(
            "Initializing. Version=%s, repo=%s, additional args=%s",
            repo_path,
            version,
            kwargs,
        )
        self.base_path = Path(repo_path)
        self.repo = Repo(self.base_path)

        self.tor_browser = bool(kwargs.get("tor_browser", True))
        self.mullvad_browser = bool(kwargs.get("mullvad_browser", True))
        if not self.tor_browser and not self.mullvad_browser:
            raise ValueError("Nothing to do")
        self.android = kwargs.get("android", self.tor_browser)
        if not self.tor_browser and self.android:
            raise ValueError("Only Tor Browser supports Android")

        logger.debug(
            "Tor Browser: %s; Mullvad Browser: %s; Android: %s",
            self.tor_browser,
            self.mullvad_browser,
            self.android,
        )

        self.yaml = ruamel.yaml.YAML()
        self.yaml.indent(mapping=2, sequence=4, offset=2)
        self.yaml.width = 4096
        self.yaml.preserve_quotes = True

        self.version = Version(version)

        self.build_date = kwargs.get("build_date", datetime.now(timezone.utc))
        self.changelog_date = kwargs.get("changelog_date", self.build_date)
        self.num_incrementals = kwargs.get("num_incrementals", 3)

        self.get_last_releases()

        logger.info("Checking you have a working GitLab token.")
        self.gitlab_token = fetch_changelogs.load_token()

    def run(self):
        self.branch_sanity_check()

        self.update_firefox()
        self.update_application_services()
        self.update_translations()
        self.update_addons()

        if self.tor_browser:
            self.update_tor()
            self.update_openssl()
            self.update_zlib()
            if self.android:
                self.update_zstd()
            self.update_go()
            self.update_manual()
            self.update_moat_settings()

        self.update_changelogs()
        self.update_rbm_conf()

        logger.info("Release preparation complete!")

    def branch_sanity_check(self):
        logger.info("Checking you are on an updated branch.")

        remote = None
        for rem in self.repo.remotes:
            if "tpo/applications/tor-browser-build" in rem.url:
                remote = rem
                break
        if remote is None:
            raise RuntimeError("Cannot find the tpo/applications remote.")

        try:
            remote.fetch()
            remote.fetch(tags=True)
        except GitCommandError:
            logger.warning(f"Cannot fetch tags from {rem.url}, skipping.")

        branch_name = (
            "main" if self.version.is_alpha else f"maint-{self.version.major}"
        )
        branch = remote.refs[branch_name]
        base = self.repo.merge_base(self.repo.head, branch)[0]
        if base != branch.commit:
            raise RuntimeError(
                "You are not working on a branch descending from "
                f"{branch_name}. "
                "Please checkout the correct branch, or pull/rebase."
            )
        logger.debug("Sanity check succeeded.")

    def update_firefox(self):
        logger.info("Updating Firefox (and GeckoView if needed)")
        config = self.load_config("firefox")

        tag_tb = None
        tag_mb = None
        if self.tor_browser:
            tag_tb = self._get_firefox_tag(config, "tor-browser")
            logger.debug(
                "Tor Browser tag: ff=%s, rebase=%s, build=%s",
                tag_tb[0],
                tag_tb[1],
                tag_tb[2],
            )
        if self.mullvad_browser:
            tag_mb = self._get_firefox_tag(config, "mullvad-browser")
            logger.debug(
                "Mullvad Browser tag: ff=%s, rebase=%s, build=%s",
                tag_mb[0],
                tag_mb[1],
                tag_mb[2],
            )
        if (
            tag_mb
            and (not tag_tb or tag_tb[2] == tag_mb[2])
            and "browser_build" in config["targets"]["mullvadbrowser"]["var"]
        ):
            logger.debug(
                "Tor Browser and Mullvad Browser are on the same build number, deleting unnecessary targets/mullvadbrowser/var/browser_build."
            )
            del config["targets"]["mullvadbrowser"]["var"]["browser_build"]
        elif tag_mb and tag_tb and tag_mb[2] != tag_tb[2]:
            config["targets"]["mullvadbrowser"]["var"]["browser_build"] = (
                tag_mb[2]
            )
            logger.debug(
                "Mismatching builds for TBB and MB, will add targets/mullvadbrowser/var/browser_build."
            )
        # We assume firefox version and rebase to be in sync
        if tag_tb:
            version = tag_tb[0]
            rebase = tag_tb[1]
            build = tag_tb[2]
        elif tag_mb:
            version = tag_mb[0]
            rebase = tag_mb[1]
            build = tag_mb[2]
        platform = version[:-3] if version.endswith("esr") else version
        config["var"]["firefox_platform_version"] = platform
        config["var"]["browser_rebase"] = rebase
        config["var"]["browser_build"] = build
        self.save_config("firefox", config)
        logger.debug("Firefox configuration saved")

        if self.android:
            assert tag_tb
            config = self.load_config("geckoview")
            config["var"]["firefox_platform_version"] = platform
            config["var"]["browser_rebase"] = rebase
            config["var"]["browser_build"] = build
            self.save_config("geckoview", config)
            logger.debug("GeckoView configuration saved")

    def _get_firefox_tag(self, config, browser):
        if browser == "mullvad-browser":
            remote = config["targets"]["mullvadbrowser"]["git_url"]
        else:
            remote = config["git_url"]
        repo = Repo(self.base_path / "git_clones/firefox")
        repo.remotes["origin"].set_url(remote)
        logger.debug("About to fetch Firefox from %s.", remote)
        repo.remotes["origin"].fetch()
        tags = get_sorted_tags(repo)
        tag_info = None
        for t in tags:
            m = re.match(
                r"(\w+-browser)-([^-]+)-([\d\.]+)-(\d+)-build(\d+)", t.tag
            )
            if (
                m
                and m.group(1) == browser
                and m.group(3) == self.version.major
            ):
                logger.debug("Matched tag %s.", t.tag)
                # firefox-version, rebase, build
                tag_info = [m.group(2), int(m.group(4)), int(m.group(5))]
                break
        if tag_info is None:
            raise RuntimeError("No compatible tag found.")
        branch = t.tag[: m.end(4)]
        logger.debug("Checking if tag %s is head of %s.", t.tag, branch)
        if t.object != repo.remotes["origin"].refs[branch].commit:
            logger.info(
                "Found new commits after tag %s, bumping the build number preemptively.",
                t.tag,
            )
            tag_info[2] += 1
        return tag_info

    def update_application_services(self):
        if not self.android:
            return

        logger.info("Updating application-services")
        config = self.load_config("application-services")
        tag = self._get_application_services_tag(config)
        build_number = tag[0]

        config["var"]["build_number"] = build_number
        self.save_config("application-services", config)
        logger.debug("application-services configuration saved")

    def _get_application_services_tag(self, config):
        version = config["version"]
        branch = f"{version}-TORBROWSER"

        repo = Repo(self.base_path / "git_clones/application-services")
        logger.debug("About to fetch application-services")
        repo.remotes["origin"].fetch()

        tags = get_sorted_tags(repo)
        tag_info = None
        for t in tags:
            logger.debug("tag: %s", t.tag)
            m = re.match(rf"v{branch}-build(\d+)", t.tag)
            if m:
                logger.debug("Matched tag %s", t.tag)
                tag_info = [int(m.group(1))]
                break
        if tag_info is None:
            raise RuntimeError("No compatible tag found.")
        logger.debug("Checking if tag %s is head of %s.", t.tag, branch)
        if t.object != repo.remotes["origin"].refs[branch].commit:
            logger.info(
                "Found new commits after tag %s, bumping the build number preemptively.",
                t.tag,
            )
            tag_info[0] += 1

        return tag_info

    def update_translations(self):
        logger.info("Updating translations")
        repo = Repo(self.base_path / "git_clones/translation")
        repo.remotes["origin"].fetch()
        config = self.load_config("translation")
        targets = ["base-browser"]
        if self.tor_browser:
            targets.append("tor-browser")
            targets.append("fenix")
        if self.mullvad_browser:
            targets.append("mullvad-browser")
        for i in targets:
            branch = config["steps"][i]["targets"]["nightly"]["git_hash"]
            config["steps"][i]["git_hash"] = str(
                repo.rev_parse(f"origin/{branch}")
            )
        self.save_config("translation", config)
        logger.debug("Translations updated")

    def update_addons(self):
        logger.info("Updating addons")
        config = self.load_config("browser")

        self.update_addon_tpo(
            config, "noscript", "{73a6fe31-595d-460b-a920-fcc0f8843232}"
        )
        if self.mullvad_browser:
            self.update_addon_amo(
                config, "ublock-origin", "uBlock0@raymondhill.net"
            )
            self.update_addon_any(
                config,
                "mullvad-extension",
                "{d19a89b9-76c1-4a61-bcd4-49e8de916403}",
                "https://cdn.mullvad.net/browser-extension/updates.json",
            )

        self.save_config("browser", config)

    def update_addon_amo(self, config, name, addon_id):
        self.update_addon_any(
            config,
            name,
            addon_id,
            f"https://services.addons.mozilla.org/api/v4/addons/addon/{addon_id}",
        )

    def update_addon_tpo(self, config, name, addon_id):
        channel = "pre" if self.version.is_alpha else "stable"
        self.update_addon_any(
            config,
            name,
            addon_id,
            f"https://dist.torproject.org/torbrowser/{name}/update-{channel}.json",
        )

    def update_addon_any(self, config, name, addon_id, updates_url):
        logger.debug("Checking updates for addon %s", name)
        r = requests.get(updates_url)
        r.raise_for_status()
        data = r.json()
        input_ = self.find_input(config, name)
        if "current_version" in data:
            # AMO matadata
            addon = data["current_version"]["files"][0]
            assert addon["hash"].startswith("sha256:")
            input_["URL"] = addon["url"]
            input_["sha256sum"] = addon["hash"][7:]
            return
        # self-hosted standalone updates.json
        url = data["addons"][addon_id]["updates"][-1]["update_link"]
        if input_["URL"] == url:
            logger.debug("No need to update the %s extension.", name)
            return
        input_["URL"] = url
        path = self.base_path / "out/browser" / url.split("/")[-1]
        # The extension should be small enough to easily fit in memory :)
        if not path.exists():
            r = requests.get(url)
            r.raise_for_status()
            with path.open("wb") as f:
                f.write(r.content)
        with path.open("rb") as f:
            input_["sha256sum"] = sha256(f.read()).hexdigest()
        logger.debug("%s extension downloaded and updated.", name)

    def update_tor(self):
        logger.info("Updating Tor")
        databag = configparser.ConfigParser()
        r = requests.get(
            "https://gitlab.torproject.org/tpo/web/tpo/-/raw/main/databags/versions.ini"
        )
        r.raise_for_status()
        databag.read_string(r.text)
        tor_stable = databag["tor-stable"]["version"]
        tor_alpha = databag["tor-alpha"]["version"]
        logger.debug(
            "Found tor stable: %s, alpha: %s",
            tor_stable,
            tor_alpha if tor_alpha else "(empty)",
        )
        if self.version.is_alpha and tor_alpha:
            version = tor_alpha
        else:
            version = tor_stable

        config = self.load_config("tor")
        if version != config["version"]:
            config["version"] = version
            self.save_config("tor", config)
            logger.debug("Tor updated to %s and config saved", version)
        else:
            logger.debug(
                "No need to update Tor (current version: %s).", version
            )

    def update_openssl(self):
        logger.info("Updating OpenSSL")
        config = self.load_config("openssl")
        version = get_github_release("openssl/openssl", r"openssl-(3.5.\d+)")
        if version == config["version"]:
            logger.debug("No need to update OpenSSL, keeping %s.", version)
            return

        config["version"] = version

        source = self.find_input(config, "openssl")
        # No need to update URL, as it uses a variable.
        hash_url = f"https://github.com/openssl/openssl/releases/download/openssl-{version}/openssl-{version}.tar.gz.sha256"
        r = requests.get(hash_url)
        r.raise_for_status()
        source["sha256sum"] = r.text.strip()[:64]
        self.save_config("openssl", config)
        logger.debug("Updated OpenSSL to %s and config saved.", version)

    def update_zlib(self):
        logger.info("Updating zlib")
        config = self.load_config("zlib")
        version = get_github_release("madler/zlib", r"v([0-9\.]+)")
        if version == config["version"]:
            logger.debug("No need to update zlib, keeping %s.", version)
            return
        config["version"] = version
        self.save_config("zlib", config)
        logger.debug("Updated zlib to %s and config saved.", version)

    def update_zstd(self):
        logger.info("Updating Zstandard")
        config = self.load_config("zstd")
        version = get_github_release("facebook/zstd", r"v([0-9\.]+)")
        if version == config["version"]:
            logger.debug("No need to update Zstandard, keeping %s.", version)
            return

        repo = Repo(self.base_path / "git_clones/zstd")
        repo.remotes["origin"].fetch()
        tag = repo.rev_parse(f"v{version}")

        config["version"] = version
        config["git_hash"] = tag.object.hexsha
        self.save_config("zstd", config)
        logger.debug(
            "Updated Zstandard to %s (commit %s) and config saved.",
            version,
            config["git_hash"],
        )

    def update_go(self):
        def get_major(v):
            major = ".".join(v.split(".")[:2])
            if major.startswith("go"):
                major = major[2:]
            return major

        logger.info("Updating Go")
        config = self.load_config("go")
        major = get_major(config["version"])

        r = requests.get("https://go.dev/dl/?mode=json")
        r.raise_for_status()
        go_versions = r.json()
        data = None
        for v in go_versions:
            if get_major(v["version"]) == major:
                data = v
                break
        if not data:
            raise KeyError("Could not find information for our Go series.")
        # Skip the "go" prefix in the version.
        config["version"] = data["version"][2:]

        sha256sum = ""
        for f in data["files"]:
            if f["kind"] == "source":
                sha256sum = f["sha256"]
                break
        if not sha256sum:
            raise KeyError("Go source package not found.")
        config["var"]["source_sha256"] = sha256sum
        self.save_config("go", config)

    def update_manual(self):
        logger.info("Updating the manual")
        update_manual(self.gitlab_token, self.base_path)

    def update_moat_settings(self):
        proj = "moat-settings"

        repo = Repo(self.base_path / "git_clones" / proj)
        origin = repo.remotes["origin"]
        origin.fetch()
        commit = origin.refs["main"].commit.hexsha

        config = self.load_config(proj)
        config["git_hash"] = commit
        self.save_config(proj, config)

    def get_last_releases(self):
        logger.info("Finding the previous releases.")
        sorted_tags = get_sorted_tags(self.repo)
        self.last_releases = {}
        self.build_number = 1
        regex = re.compile(r"(\w+)-([\d\.a]+)-build(\d+)")
        num_releases = 0
        for t in sorted_tags:
            m = regex.match(t.tag)
            project = m.group(1)
            version = Version(m.group(2))
            build = int(m.group(3))
            if version == self.version:
                # A previous tag, we can use it to bump our build.
                if self.build_number == 1:
                    self.build_number = build + 1
                    logger.debug(
                        "Found previous tag for the version we are preparing: %s. Bumping build number to %d.",
                        t.tag,
                        self.build_number,
                    )
                continue
            key = (project, version.channel)
            if key not in self.last_releases:
                self.last_releases[key] = []
            skip = False
            for rel in self.last_releases[key]:
                # Tags are already sorted: higher builds should come
                # first.
                if rel.version == version:
                    skip = True
                    logger.debug(
                        "Additional build for a version we already found, skipping: %s",
                        t.tag,
                    )
                    break
            if skip:
                continue
            if len(self.last_releases[key]) != self.num_incrementals:
                logger.debug(
                    "Found tag to potentially build incrementals from: %s.",
                    t.tag,
                )
                self.last_releases[key].append(ReleaseTag(t, version))
                num_releases += 1
            if num_releases == self.num_incrementals * 4:
                break

    def update_changelogs(self):
        if self.tor_browser:
            logger.info("Updating changelogs for Tor Browser")
            self.make_changelogs("tbb")
        if self.mullvad_browser:
            logger.info("Updating changelogs for Mullvad Browser")
            self.make_changelogs("mb")

    def make_changelogs(self, tag_prefix):
        locale.setlocale(locale.LC_TIME, "C")
        kwargs = {"date": self.changelog_date.strftime("%B %d %Y")}
        prev_tag = self.last_releases[(tag_prefix, self.version.channel)][
            0
        ].tag
        self.check_update(
            kwargs, prev_tag, "firefox", ["var", "firefox_platform_version"]
        )
        if "firefox" in kwargs:
            # Sometimes this might be incorrect for alphas, but let's
            # keep it for now.
            kwargs["firefox"] += "esr"
        self.check_update(kwargs, prev_tag, "tor")
        self.check_update(kwargs, prev_tag, "openssl")
        self.check_update(kwargs, prev_tag, "zlib")
        self.check_update(kwargs, prev_tag, "zstd")
        self.check_update(kwargs, prev_tag, "go")
        self.check_update_extensions(kwargs, prev_tag)
        logger.debug("Changelog arguments for %s: %s", tag_prefix, kwargs)
        cb = fetch_changelogs.ChangelogBuilder(
            self.gitlab_token, str(self.version), is_mullvad=tag_prefix == "mb"
        )
        changelogs = cb.create(**kwargs)

        path = f"projects/browser/Bundle-Data/Docs-{tag_prefix.upper()}/ChangeLog.txt"
        # Take HEAD to reset any changes we might already have from a
        # previous run.
        last_changelogs = self.repo.git.show(f"HEAD:{path}")
        with (self.base_path / path).open("w") as f:
            f.write(changelogs + "\n" + last_changelogs + "\n")

    def check_update(self, updates, prev_tag, project, key=["version"]):
        old_val = self.load_old_config(prev_tag.tag, project)
        new_val = self.load_config(project)
        for k in key:
            old_val = old_val[k]
            new_val = new_val[k]
        if old_val != new_val:
            updates[project] = new_val

    def check_update_extensions(self, updates, prev_tag):
        old_config = self.load_old_config(prev_tag, "browser")
        new_config = self.load_config("browser")
        keys = {
            "noscript": "noscript",
            "mb_extension": "mullvad-extension",
            "ublock": "ublock-origin",
        }
        regex = re.compile(r"-([0-9\.]+).xpi$")
        for update_key, input_name in keys.items():
            old_url = self.find_input(old_config, input_name)["URL"]
            new_url = self.find_input(new_config, input_name)["URL"]
            old_version = regex.findall(old_url)[0]
            new_version = regex.findall(new_url)[0]
            if old_version != new_version:
                updates[update_key] = new_version

    def update_rbm_conf(self):
        logger.info("Updating rbm.conf.")
        releases = {}
        browsers = {
            "tbb": '[% IF c("var/tor-browser") %]{}[% END %]',
            "mb": '[% IF c("var/mullvad-browser") %]{}[% END %]',
        }
        incremental_from = []
        for b in ["tbb", "mb"]:
            for rel in self.last_releases[(b, self.version.channel)]:
                if rel.version not in releases:
                    releases[rel.version] = {}
                releases[rel.version][b] = str(rel.version)
        for version in sorted(releases.keys(), reverse=True):
            if len(releases[version]) == 2:
                incremental_from.append(releases[version]["tbb"])
                logger.debug(
                    "Building incremental from %s for both browsers.", version
                )
            else:
                for b, template in browsers.items():
                    maybe_rel = releases[version].get(b)
                    if maybe_rel:
                        logger.debug(
                            "Building incremental from %s only for %s.",
                            version,
                            b,
                        )
                        incremental_from.append(template.format(maybe_rel))

        separator = "\n--- |\n"
        path = self.base_path / "rbm.conf"
        with path.open() as f:
            docs = f.read().split(separator, 2)
        config = self.yaml.load(docs[0])
        config["var"]["torbrowser_version"] = str(self.version)
        config["var"]["torbrowser_build"] = f"build{self.build_number}"
        config["var"]["torbrowser_incremental_from"] = incremental_from
        config["var"]["browser_release_date"] = self.build_date.strftime(
            "%Y/%m/%d %H:%M:%S"
        )
        with path.open("w") as f:
            self.yaml.dump(config, f)
            f.write(separator)
            f.write(docs[1])

    def load_config(self, project):
        config_path = self.base_path / f"projects/{project}/config"
        return self.yaml.load(config_path)

    def load_old_config(self, committish, project):
        treeish = f"{committish}:projects/{project}/config"
        return self.yaml.load(self.repo.git.show(treeish))

    def save_config(self, project, config):
        config_path = self.base_path / f"projects/{project}/config"
        with config_path.open("w") as f:
            self.yaml.dump(config, f)

    def find_input(self, config, name):
        for entry in config["input_files"]:
            if "name" in entry and entry["name"] == name:
                return entry
        raise KeyError(f"Input {name} not found.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-r",
        "--repository",
        type=Path,
        default=Path(__file__).parent.parent,
        help="Path to a tor-browser-build.git clone",
    )
    parser.add_argument("--tor-browser", action="store_true")
    parser.add_argument("--mullvad-browser", action="store_true")
    parser.add_argument(
        "--date",
        help="Release date and optionally time for changelog purposes. "
        "It must be understandable by datetime.fromisoformat.",
    )
    parser.add_argument(
        "--build-date",
        help="Build date. It cannot not be in the future when running the build.",
    )
    parser.add_argument(
        "--incrementals", type=int, help="The number of incrementals to create"
    )
    parser.add_argument(
        "--only-changelogs",
        action="store_true",
        help="Only update the changelogs",
    )
    parser.add_argument(
        "--log-level",
        choices=["debug", "info", "warning", "error"],
        default="info",
        help="Set the log level",
    )
    parser.add_argument("version")

    args = parser.parse_args()

    # Logger adapted from https://stackoverflow.com/a/56944256.
    log_level = getattr(logging, args.log_level.upper())
    logger.setLevel(log_level)
    ch = logging.StreamHandler()
    ch.setLevel(log_level)
    ch.setFormatter(
        logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s (%(filename)s:%(lineno)d)",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
    )
    logger.addHandler(ch)

    tbb = bool(args.tor_browser)
    mb = bool(args.mullvad_browser)
    kwargs = {}
    if tbb or mb:
        kwargs["tor_browser"] = tbb
        kwargs["mullvad_browser"] = mb
    if args.date:
        try:
            kwargs["changelog_date"] = datetime.fromisoformat(args.date)
        except ValueError:
            print("Invalid date supplied.", file=sys.stderr)
            sys.exit(1)
    if args.build_date:
        try:
            kwargs["build_date"] = datetime.fromisoformat(args.date)
        except ValueError:
            print("Invalid date supplied.", file=sys.stderr)
            sys.exit(1)
    if args.incrementals:
        kwargs["incrementals"] = args.incrementals
    rp = ReleasePreparation(args.repository, args.version, **kwargs)
    if args.only_changelogs:
        logger.info("Updating only the changelogs")
        rp.update_changelogs()
    else:
        logger.debug("Running a complete release preparation.")
        rp.run()
