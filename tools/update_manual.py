#!/usr/bin/env python3
import hashlib
from pathlib import Path

import requests
import ruamel.yaml

from fetch_changelogs import load_token, AUTH_HEADER


GITLAB = "https://gitlab.torproject.org"
API_URL = f"{GITLAB}/api/v4"
PROJECT_ID = 23
REF_NAME = "main"


def find_job(auth_token):
    r = requests.get(
        f"{API_URL}/projects/{PROJECT_ID}/jobs",
        headers={AUTH_HEADER: auth_token},
    )
    r.raise_for_status()
    for job in r.json():
        if job["ref"] != REF_NAME:
            continue
        for artifact in job["artifacts"]:
            if artifact["filename"] == "artifacts.zip":
                return job


def update_config(base_path, pipeline_id, sha256):
    yaml = ruamel.yaml.YAML()
    yaml.indent(mapping=2, sequence=4, offset=2)
    yaml.width = 150
    yaml.preserve_quotes = True

    config_path = base_path / "projects/manual/config"
    config = yaml.load(config_path)
    if int(config["version"]) == pipeline_id:
        return False

    config["version"] = pipeline_id
    for input_file in config["input_files"]:
        if input_file.get("name") == "manual":
            input_file["sha256sum"] = sha256
            break
    with config_path.open("w") as f:
        yaml.dump(config, f)
    return True

def download_manual(url, dest):
    r = requests.get(url, stream=True)
    # https://stackoverflow.com/a/16696317
    r.raise_for_status()
    sha256 = hashlib.sha256()
    with dest.open("wb") as f:
        for chunk in r.iter_content(chunk_size=8192):
            f.write(chunk)
            sha256.update(chunk)
    return sha256.hexdigest()


def update_manual(auth_token, base_path):
    job = find_job(auth_token)
    if job is None:
        raise RuntimeError("No usable job found")
    pipeline_id = int(job["pipeline"]["id"])

    manual_fname = f"manual_{pipeline_id}.zip"
    url = f"https://build-sources.tbb.torproject.org/{manual_fname}"
    r = requests.head(url)
    needs_upload = r.status_code != 200

    manual_dir = base_path / "out/manual"
    manual_dir.mkdir(0o755, parents=True, exist_ok=True)
    manual_file = manual_dir / manual_fname
    if manual_file.exists():
        sha256 = hashlib.sha256()
        with manual_file.open("rb") as f:
            while chunk := f.read(8192):
                sha256.update(chunk)
        sha256 = sha256.hexdigest()
    elif not needs_upload:
        sha256 = download_manual(url, manual_file)
    else:
        url = f"{API_URL}/projects/{PROJECT_ID}/jobs/artifacts/{REF_NAME}/download?job={job['name']}"
        sha256 = download_manual(url, manual_file)

    if needs_upload:
        print(f"New manual version: {manual_file}.")
        print(
            "Please upload it to tb-build-02.torproject.org:~tb-builder/public_html/."
        )

    return update_config(base_path, pipeline_id, sha256)

if __name__ == "__main__":
    if update_manual(load_token(), Path(__file__).parent.parent):
        print("Manual config updated, remember to stage it!")
    else:
        print("Manual already latest")
