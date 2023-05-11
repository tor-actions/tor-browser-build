#!/usr/bin/env python3
from datetime import datetime
import enum
from pathlib import Path
import sys

import requests


GITLAB = "https://gitlab.torproject.org"
API_URL = f"{GITLAB}/api/v4"
PROJECT_ID = 473


class Platform(enum.IntFlag):
    WINDOWS = 8
    MACOS = 4
    LINUX = 2
    ANDROID = 1
    DESKTOP = 8 | 4 | 2
    ALL_PLATFORMS = 8 | 4 | 2 | 1


class Issue:
    def __init__(self, j):
        self.title = j["title"]
        self.project, self.number = (
            j["references"]["full"].rsplit("/", 2)[-1].split("#")
        )
        self.platform = 0
        self.num_platforms = 0
        if "Desktop" in j["labels"]:
            self.platform = Platform.DESKTOP
            self.num_platforms += 3
        else:
            if "Windows" in j["labels"]:
                self.platform |= Platform.WINDOWS
                self.num_platforms += 1
            if "MacOS" in j["labels"]:
                self.platform |= Platform.MACOS
                self.num_platforms += 1
            if "Linux" in j["labels"]:
                self.platform |= Platform.LINUX
                self.num_platforms += 1
        if "Android" in j["labels"]:
            self.platform |= Platform.ANDROID
            self.num_platforms += 1
        if not self.platform:
            self.platform = Platform.ALL_PLATFORMS
            self.num_platforms = 4
        self.is_build = "Build System" in j["labels"]

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

    def __str__(self):
        return f"Bug {self.number}: {self.title} [{self.project}]"

    def __lt__(self, other):
        return self.number < other.number


def sorted_issues(issues):
    issues = [sorted(v) for v in issues.values()]
    return sorted(
        issues,
        key=lambda group: (group[0].num_platforms << 8) | group[0].platform,
        reverse=True,
    )


if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} version-to-release or #issue-id")
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

version = sys.argv[1]
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
    if i["title"].find(sys.argv[1]) != -1:
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
    version = None
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
    except ValueError:
        pass
if not issue:
    print(
        "Release preparation issue not found. Please make sure it has ~Release Prep."
    )
    sys.exit(5)
iid = issue["iid"]

linked = {}
linked_build = {}
r = requests.get(
    f"{API_URL}/projects/{PROJECT_ID}/issues/{iid}/links", headers=headers
)
for i in r.json():
    i = Issue(i)
    target = linked_build if i.is_build else linked
    if i.platform not in target:
        target[i.platform] = []
    target[i.platform].append(i)
linked = sorted_issues(linked)
linked_build = sorted_issues(linked_build)

date = datetime.now().strftime("%B %d %Y")
print(f"Tor Browser {version} - {date}")
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
