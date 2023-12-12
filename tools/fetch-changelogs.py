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

is_mb = False
project_order = {
    "tor-browser-spec": 0,
    # Leave 1 free, so we can redefine mullvad-browser when needed.
    "tor-browser": 2,
    "tor-browser-build": 3,
    "mullvad-browser": 4,
    "rbm": 5,
}


class EntryType(enum.IntFlag):
    UPDATE = 0
    ISSUE = 1


class Platform(enum.IntFlag):
    WINDOWS = 8
    MACOS = 4
    LINUX = 2
    ANDROID = 1
    DESKTOP = 8 | 4 | 2
    ALL_PLATFORMS = 8 | 4 | 2 | 1


class ChangelogEntry:
    def __init__(self, type_, platform, num_platforms, is_build):
        self.type = type_
        self.platform = platform
        self.num_platforms = num_platforms
        self.is_build = is_build

    def get_platforms(self):
        if self.platform == Platform.ALL_PLATFORMS:
            return "All Platforms"
        platforms = []
        if self.platform & Platform.WINDOWS:
            platforms.append("Windows")
        if self.platform & Platform.MACOS:
            platforms.append("macOS")
        if self.platform & Platform.LINUX:
            platforms.append("Linux")
        if self.platform & Platform.ANDROID:
            platforms.append("Android")
        return " + ".join(platforms)

    def __lt__(self, other):
        if self.type != other.type:
            return self.type < other.type
        if self.type == EntryType.UPDATE:
            # Rely on sorting being stable on Python
            return False
        if self.project == other.project:
            return self.number < other.number
        return project_order[self.project] < project_order[other.project]


class UpdateEntry(ChangelogEntry):
    def __init__(self, name, version):
        if name == "Firefox" and not is_mb:
            platform = Platform.DESKTOP
            num_platforms = 3
        elif name == "GeckoView":
            platform = Platform.ANDROID
            num_platforms = 3
        else:
            platform = Platform.ALL_PLATFORMS
            num_platforms = 4
        super().__init__(
            EntryType.UPDATE, platform, num_platforms, name == "Go"
        )
        self.name = name
        self.version = version

    def __str__(self):
        return f"Updated {self.name} to {self.version}"


class Issue(ChangelogEntry):
    def __init__(self, j):
        self.title = j["title"]
        self.project, self.number = (
            j["references"]["full"].rsplit("/", 2)[-1].split("#")
        )
        self.number = int(self.number)
        platform = 0
        num_platforms = 0
        if "Desktop" in j["labels"]:
            platform = Platform.DESKTOP
            num_platforms += 3
        else:
            if "Windows" in j["labels"]:
                platform |= Platform.WINDOWS
                num_platforms += 1
            if "MacOS" in j["labels"]:
                platform |= Platform.MACOS
                num_platforms += 1
            if "Linux" in j["labels"]:
                platform |= Platform.LINUX
                num_platforms += 1
        if "Android" in j["labels"]:
            if is_mb and num_platforms == 0:
                raise Exception(
                    f"Android-only issue on Mullvad Browser: {j['references']['full']}!"
                )
            elif not is_mb:
                platform |= Platform.ANDROID
                num_platforms += 1
        if not platform or (is_mb and platform == Platform.DESKTOP):
            platform = Platform.ALL_PLATFORMS
            num_platforms = 4
        is_build = "Build System" in j["labels"]
        super().__init__(EntryType.ISSUE, platform, num_platforms, is_build)

    def __str__(self):
        return f"Bug {self.number}: {self.title} [{self.project}]"


def sorted_issues(issues):
    issues = [sorted(v) for v in issues.values()]
    return sorted(
        issues,
        key=lambda group: (group[0].num_platforms << 8) | group[0].platform,
        reverse=True,
    )


parser = argparse.ArgumentParser()
parser.add_argument("issue_version")
parser.add_argument("--date", help="The date of the release")
parser.add_argument("--firefox", help="New Firefox version (if we rebased)")
parser.add_argument("--tor", help="New Tor version (if updated)")
parser.add_argument("--no-script", help="New NoScript version (if updated)")
parser.add_argument("--openssl", help="New OpenSSL version (if updated)")
parser.add_argument("--ublock", help="New uBlock version (if updated)")
parser.add_argument("--zlib", help="New zlib version (if updated)")
parser.add_argument("--go", help="New Go version (if updated)")
args = parser.parse_args()

if not args.issue_version:
    parser.print_help()
    sys.exit(1)

token_file = Path(__file__).parent / ".changelogs_token"
if not token_file.exists():
    print(
        f"Please add your personal GitLab token (with 'read_api' scope) to {token_file}"
    )
    print(
        f"Please go to {GITLAB}/-/profile/personal_access_tokens and generate it."
    )
    token = input("Please enter the new token: ").strip()
    if not token:
        print("Invalid token!")
        sys.exit(2)
    with token_file.open("w") as f:
        f.write(token)
with token_file.open() as f:
    token = f.read().strip()
headers = {"PRIVATE-TOKEN": token}

version = args.issue_version
r = requests.get(
    f"{API_URL}/projects/{PROJECT_ID}/issues?labels=Release Prep",
    headers=headers,
)
if r.status_code == 401:
    print("Unauthorized! Has your token expired?")
    sys.exit(3)
issue = None
issues = []
for i in r.json():
    if i["title"].find(version) != -1:
        issues.append(i)
if len(issues) == 1:
    issue = issues[0]
elif len(issues) > 1:
    print("More than one matching issue found:")
    for idx, i in enumerate(issues):
        print(f"  {idx + 1}) #{i['iid']} - {i['title']}")
    print("Please use the issue id.")
    sys.exit(4)
else:
    iid = version
    version = "CHANGEME!"
    if iid[0] == "#":
        iid = iid[1:]
    try:
        int(iid)
        r = requests.get(
            f"{API_URL}/projects/{PROJECT_ID}/issues?iids={iid}",
            headers=headers,
        )
        if r.ok and r.json():
            issue = r.json()[0]
            version_match = re.search(r"\b[0-9]+\.[.0-9a]+\b", issue["title"])
            if version_match:
                version = version_match.group()
    except ValueError:
        pass
if not issue:
    print(
        "Release preparation issue not found. Please make sure it has ~Release Prep."
    )
    sys.exit(5)
if "Sponsor 131" in issue["labels"]:
    is_mb = True
    project_order["mullvad-browser"] = 1
iid = issue["iid"]

linked = {}
linked_build = {}


def add_entry(entry):
    target = linked_build if entry.is_build else linked
    if entry.platform not in target:
        target[entry.platform] = []
    target[entry.platform].append(entry)


if args.firefox:
    add_entry(UpdateEntry("Firefox", args.firefox))
    if not is_mb:
        add_entry(UpdateEntry("GeckoView", args.firefox))
if args.tor and not is_mb:
    add_entry(UpdateEntry("Tor", args.tor))
if args.no_script:
    add_entry(UpdateEntry("NoScript", args.no_script))
if not is_mb:
    if args.openssl:
        add_entry(UpdateEntry("OpenSSL", args.openssl))
    if args.zlib:
        add_entry(UpdateEntry("zlib", args.zlib))
    if args.go:
        add_entry(UpdateEntry("Go", args.go))
elif args.ublock:
    add_entry(UpdateEntry("uBlock Origin", args.ublock))

r = requests.get(
    f"{API_URL}/projects/{PROJECT_ID}/issues/{iid}/links", headers=headers
)
for i in r.json():
    add_entry(Issue(i))

linked = sorted_issues(linked)
linked_build = sorted_issues(linked_build)

name = "Mullvad" if is_mb else "Tor"
date = args.date if args.date else datetime.now().strftime("%B %d %Y")
print(f"{name} Browser {version} - {date}")
for issues in linked:
    print(f" * {issues[0].get_platforms()}")
    for i in issues:
        print(f"   * {i}")
if linked_build:
    print(" * Build System")
    for issues in linked_build:
        print(f"   * {issues[0].get_platforms()}")
        for i in issues:
            print(f"     * {i}")
