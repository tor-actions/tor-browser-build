#!/usr/bin/env python3
import argparse
from pathlib import Path
import sys

import requests

GITLAB = "https://gitlab.torproject.org"
API_URL = f"{GITLAB}/api/v4"
AUTH_HEADER = "PRIVATE-TOKEN"
PROTECT_LEVEL = 40  # Maintainer

parser = argparse.ArgumentParser()
parser.add_argument("browser", choices=["tor-browser", "mullvad-browser"])
parser.add_argument("firefox_version")
parser.add_argument("our_major")
parser.add_argument("--rebase", type=int, default=1)
args = parser.parse_args()

project_id = 1817 if args.browser == "mullvad-browser" else 472
endpoint = f"{API_URL}/projects/{project_id}/protected_branches"

token_file = Path(__file__).parent.parent / ".changelogs_token"
if not token_file.exists():
    print("Token not found, please create it.")
    sys.exit(1)
with token_file.open() as f:
    token = f.read().strip()
headers = {AUTH_HEADER: token}

r = requests.get(endpoint, headers=headers)
r.raise_for_status()
rules = r.json()
for rule in rules:
    if f"-{args.our_major}-" in rule["name"]:
        r = requests.delete(f"{endpoint}/{rule['name']}", headers=headers)
        r.raise_for_status()


def protect_branch(product):
    data = {
        "id": project_id,
        "name": f"{product}-{args.firefox_version}-{args.our_major}-{args.rebase}",
        "allow_force_push": False,
        "merge_access_level": PROTECT_LEVEL,
        "push_access_level": PROTECT_LEVEL,
    }
    r = requests.post(endpoint, json=data, headers=headers)
    r.raise_for_status()


protect_branch(args.browser)
if args.browser == "tor-browser":
    protect_branch("base-browser")
