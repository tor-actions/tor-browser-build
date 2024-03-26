#!/usr/bin/env python3
import hashlib
from pathlib import Path
import sys

import requests
import yaml


GITLAB = "https://gitlab.torproject.org"
API_URL = f"{GITLAB}/api/v4"
PROJECT_ID = 23
REF_NAME = "main"


token_file = Path(__file__).parent / ".changelogs_token"
if not token_file.exists():
    print("This scripts uses the same access token as fetch-changelog.py.")
    print("However, the file has not been found.")
    print(
        "Please run fetch-changelog.py to get the instructions on how to "
        "generate it."
    )
    sys.exit(1)
with token_file.open() as f:
    headers = {"PRIVATE-TOKEN": f.read().strip()}

r = requests.get(f"{API_URL}/projects/{PROJECT_ID}/jobs", headers=headers)
if r.status_code == 401:
    print("Unauthorized! Maybe the token has expired.")
    sys.exit(2)
found = False
for job in r.json():
    if job["ref"] != REF_NAME:
        continue
    for art in job["artifacts"]:
        if art["filename"] == "artifacts.zip":
            found = True
            break
    if found:
        break
if not found:
    print("Cannot find a usable job.")
    sys.exit(3)

pipeline_id = job["pipeline"]["id"]
conf_file = Path(__file__).parent.parent / "projects/manual/config"
with conf_file.open() as f:
    config = yaml.load(f, yaml.SafeLoader)
if int(config["version"]) == int(pipeline_id):
    print(
        "projects/manual/config is already using the latest pipeline. Nothing to do."
    )
    sys.exit(0)

manual_dir = Path(__file__).parent.parent / "out/manual"
manual_dir.mkdir(0o755, parents=True, exist_ok=True)
manual_file = manual_dir / f"manual_{pipeline_id}.zip"
sha256 = hashlib.sha256()
if manual_file.exists():
    with manual_file.open("rb") as f:
        while chunk := f.read(8192):
            sha256.update(chunk)
    print("You already have the latest manual version in your out directory.")
    print("Please update projects/manual/config to:")
else:
    print("Downloading the new version of the manual...")
    url = f"{API_URL}/projects/{PROJECT_ID}/jobs/artifacts/{REF_NAME}/download?job={job['name']}"
    r = requests.get(url, headers=headers, stream=True)
    # https://stackoverflow.com/a/16696317
    r.raise_for_status()
    with manual_file.open("wb") as f:
        for chunk in r.iter_content(chunk_size=8192):
            f.write(chunk)
            sha256.update(chunk)
    print(f"File downloaded as {manual_file}.")
    print(
        "Please upload it to tb-build-02.torproject.org:~tb-builder/public_html/. and then update projects/manual/config:"
    )
sha256 = sha256.hexdigest()

print(f"\tversion: {pipeline_id}")
print(f"\tSHA256: {sha256}")
