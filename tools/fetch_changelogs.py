#!/usr/bin/env python3
import argparse
from datetime import datetime
import enum
from pathlib import Path
import re
import sys

import requests


GITLAB = "https://gitlab.torproject.org"
API_URL = f"{GITLAB}/api/v4"
PROJECT_ID = 473
AUTH_HEADER = "PRIVATE-TOKEN"


class EntryType(enum.IntFlag):
    UPDATE = 0
    ISSUE = 1


class Platform(enum.IntFlag):
    WINDOWS = 2
    MACOS = 1
    DESKTOP = 2 | 1
    ALL_PLATFORMS = 2 | 1


class ChangelogEntry:
    def __init__(self, type_, platform, num_platforms, is_build, is_mb):
        self.type = type_
        self.platform = platform
        self.num_platforms = num_platforms
        self.is_build = is_build
        self.project_order = {
            "tor-browser-spec": 0,
            # Leave 1 free, so we can redefine mullvad-browser when needed.
            "tor-browser": 2,
            "tor-browser-build": 3,
            "mullvad-browser": 1 if is_mb else 4,
            "rbm": 5,
        }

    def get_platforms(self):
        if self.platform == Platform.ALL_PLATFORMS:
            return "All Platforms"
        platforms = []
        if self.platform & Platform.WINDOWS:
            platforms.append("Windows")
        if self.platform & Platform.MACOS:
            platforms.append("macOS")
        return " + ".join(platforms)

    def __lt__(self, other):
        if self.num_platforms != other.num_platforms:
            return self.num_platforms > other.num_platforms
        if self.platform != other.platform:
            return self.platform > other.platform
        if self.type != other.type:
            return self.type < other.type
        if self.type == EntryType.UPDATE:
            # Rely on sorting being stable on Python
            return False
        if self.project == other.project:
            return self.number < other.number
        return (
            self.project_order[self.project]
            < self.project_order[other.project]
        )


class UpdateEntry(ChangelogEntry):
    def __init__(self, name, version, is_mb):
        platform = Platform.ALL_PLATFORMS
        num_platforms = 2
        super().__init__(
            EntryType.UPDATE, platform, num_platforms, name == "Go", is_mb
        )
        self.name = name
        self.version = version

    def __str__(self):
        return f"Updated {self.name} to {self.version}"


class Issue(ChangelogEntry):
    def __init__(self, j, is_mb):
        self.title = j["title"]
        self.project, self.number = (
            j["references"]["full"].rsplit("/", 2)[-1].split("#")
        )
        self.number = int(self.number)
        platform = 0
        num_platforms = 0
        if "Desktop" in j["labels"]:
            platform = Platform.ALL_PLATFORMS
            num_platforms += 2
        else:
            if "Windows" in j["labels"]:
                platform |= Platform.WINDOWS
                num_platforms += 1
            if "MacOS" in j["labels"]:
                platform |= Platform.MACOS
                num_platforms += 1
        if not platform:
            if "Android" in j["labels"] or "Linux" in j["labels"]:
                raise Exception(
                    f"The legacy channel should include only fixes for macOS and/or Windows, please check {self.project}#{self.number}."
                )
            platform = Platform.ALL_PLATFORMS
            num_platforms = 2
        is_build = "Build System" in j["labels"]
        super().__init__(
            EntryType.ISSUE, platform, num_platforms, is_build, is_mb
        )

    def __str__(self):
        return f"Bug {self.number}: {self.title} [{self.project}]"


class ChangelogBuilder:

    def __init__(self, auth_token, issue_or_version, is_mullvad=None):
        self.headers = {AUTH_HEADER: auth_token}
        self._find_issue(issue_or_version, is_mullvad)

    def _find_issue(self, issue_or_version, is_mullvad):
        self.version = None
        if issue_or_version[0] == "#":
            self._fetch_issue(issue_or_version[1:], is_mullvad)
            return
        labels = "Apps::Type::ReleasePreparation"
        if is_mullvad:
            labels += ",Sponsor 131"
        elif not is_mullvad and is_mullvad is not None:
            labels += "&not[labels]=Sponsor 131"
        r = requests.get(
            f"{API_URL}/projects/{PROJECT_ID}/issues?labels={labels}&search={issue_or_version}&in=title&state=opened",
            headers=self.headers,
        )
        r.raise_for_status()
        issues = r.json()
        if len(issues) == 1:
            self.version = issue_or_version
            self._set_issue(issues[0], is_mullvad)
        elif len(issues) > 1:
            raise ValueError(
                "Multiple issues found, try to specify the browser."
            )
        else:
            self._fetch_issue(issue_or_version, is_mullvad)

    def _fetch_issue(self, number, is_mullvad):
        try:
            # Validate the string to be an integer
            number = int(number)
        except ValueError:
            # This is called either as a last chance, or because we
            # were given "#", so this error should be good.
            raise ValueError("Issue not found")
        r = requests.get(
            f"{API_URL}/projects/{PROJECT_ID}/issues?iids[]={number}",
            headers=self.headers,
        )
        r.raise_for_status()
        issues = r.json()
        if len(issues) != 1:
            # It should be only 0, since we used the number...
            raise ValueError("Issue not found")
        self._set_issue(issues[0], is_mullvad)

    def _set_issue(self, issue, is_mullvad):
        has_s131 = "Sponsor 131" in issue["labels"]
        if is_mullvad is not None and is_mullvad != has_s131:
            raise ValueError(
                "Inconsistency detected: a browser was explicitly specified, but the issue does not have the correct labels."
            )
        self.relprep_issue = issue["iid"]
        self.is_mullvad = has_s131

        if self.version is None:
            version_match = re.search(r"\b[0-9]+\.[.0-9a]+\b", issue["title"])
            if version_match:
                self.version = version_match.group()

    def create(self, **kwargs):
        self._find_linked(
            kwargs.get("include_from"), kwargs.get("exclude_from")
        )
        self._add_updates(kwargs)
        self._sort_issues()
        name = "Mullvad" if self.is_mullvad else "Tor"
        date = (
            kwargs["date"]
            if kwargs.get("date")
            else datetime.now().strftime("%B %d %Y")
        )
        text = f"{name} Browser {self.version} - {date}\n"
        prev_platform = ""
        for issue in self.issues:
            platform = issue.get_platforms()
            if platform != prev_platform:
                text += f" * {platform}\n"
                prev_platform = platform
            text += f"   * {issue}\n"
        if self.issues_build:
            text += " * Build System\n"
            prev_platform = ""
            for issue in self.issues_build:
                platform = issue.get_platforms()
                if platform != prev_platform:
                    text += f"   * {platform}\n"
                    prev_platform = platform
                text += f"     * {issue}\n"
        return text

    def _find_linked(self, include_relpreps=[], exclude_relpreps=[]):
        self.issues = []
        self.issues_build = []

        if include_relpreps is None:
            include_relpreps = [self.relprep_issue]
        elif self.relprep_issue not in include_relpreps:
            include_relpreps.append(self.relprep_issue)
        if exclude_relpreps is None:
            exclude_relpreps = []

        included = {}
        excluded = set()
        for relprep in include_relpreps:
            included.update(
                {
                    issue["references"]["full"]: issue
                    for issue in self._get_linked_issues(relprep)
                }
            )
        for relprep in exclude_relpreps:
            excluded.update(
                [
                    issue["references"]["full"]
                    for issue in self._get_linked_issues(relprep)
                ]
            )
        for ex in excluded:
            if ex in included:
                included.pop(ex)
        for data in included.values():
            self._add_issue(data)

    def _get_linked_issues(self, issue_id):
        r = requests.get(
            f"{API_URL}/projects/{PROJECT_ID}/issues/{issue_id}/links",
            headers=self.headers,
        )
        r.raise_for_status()
        return r.json()

    def _add_issue(self, gitlab_data):
        self._add_entry(Issue(gitlab_data, self.is_mullvad))

    def _add_entry(self, entry):
        target = self.issues_build if entry.is_build else self.issues
        target.append(entry)

    def _add_updates(self, updates):
        names = {
            "Firefox": "firefox",
            "NoScript": "noscript",
        }
        if not self.is_mullvad:
            names.update(
                {
                    "Tor": "tor",
                    "OpenSSL": "openssl",
                    "zlib": "zlib",
                    "Zstandard": "zstd",
                    "Go": "go",
                }
            )
        else:
            names.update(
                {
                    "Mullvad Browser Extension": "mb_extension",
                    "uBlock Origin": "ublock",
                }
            )
        for name, key in names.items():
            self._maybe_add_update(name, updates, key)

    def _maybe_add_update(self, name, updates, key):
        if updates.get(key):
            self._add_entry(UpdateEntry(name, updates[key], self.is_mullvad))

    def _sort_issues(self):
        self.issues.sort()
        self.issues_build.sort()


def load_token(test=True, interactive=True):
    token_path = Path(__file__).parent / ".changelogs_token"

    if token_path.exists():
        with token_path.open() as f:
            token = f.read().strip()
    elif interactive:
        print(
            f"Please add your personal GitLab token (with 'read_api' scope) to {token_path}"
        )
        print(
            f"Please go to {GITLAB}/-/profile/personal_access_tokens and generate it."
        )
        token = input("Please enter the new token: ").strip()
        if not token:
            raise ValueError("Invalid token!")
        with token_path.open("w") as f:
            f.write(token)
    if test:
        r = requests.get(f"{API_URL}/version", headers={AUTH_HEADER: token})
        if r.status_code == 401:
            raise ValueError("The loaded or provided token does not work.")
    return token


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("issue_version")
    parser.add_argument("-d", "--date", help="The date of the release")
    parser.add_argument(
        "-b", "--browser", choices=["tor-browser", "mullvad-browser"]
    )
    parser.add_argument(
        "--firefox", help="New Firefox version (if we rebased)"
    )
    parser.add_argument("--tor", help="New Tor version (if updated)")
    parser.add_argument(
        "--noscript", "--no-script", help="New NoScript version (if updated)"
    )
    parser.add_argument("--openssl", help="New OpenSSL version (if updated)")
    parser.add_argument("--zlib", help="New zlib version (if updated)")
    parser.add_argument("--zstd", help="New zstd version (if updated)")
    parser.add_argument("--go", help="New Go version (if updated)")
    parser.add_argument(
        "--mb-extension",
        help="New Mullvad Browser Extension version (if updated)",
    )
    parser.add_argument("--ublock", help="New uBlock version (if updated)")
    parser.add_argument(
        "--exclude-from",
        help="Relprep issues to remove entries from, useful when doing a major release",
        nargs="*",
    )
    parser.add_argument(
        "--include-from",
        help="Relprep issues to add entries from, useful when doing a major release",
        nargs="*",
    )
    args = parser.parse_args()

    if not args.issue_version:
        parser.print_help()
        sys.exit(1)

    try:
        token = load_token()
    except ValueError:
        print(
            "Invalid authentication token. Maybe has it expired?",
            file=sys.stderr,
        )
        sys.exit(2)
    is_mullvad = args.browser == "mullvad-browser" if args.browser else None
    cb = ChangelogBuilder(token, args.issue_version, is_mullvad)
    print(cb.create(**vars(args)))
