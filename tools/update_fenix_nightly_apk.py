#!/usr/bin/env python3
import hashlib
import re
from pathlib import Path

import requests
import ruamel.yaml


def find_apk_url():
    base_url = "https://ftp.mozilla.org"
    path = "/pub/fenix/nightly/"
    while True:
        url = f"{base_url}{path}"
        r = requests.get(url)
        r.raise_for_status()
        match = re.match(f'.*"({re.escape(path)}.*)"', r.text, re.DOTALL)
        if not match:
            raise Exception(f"Could not find apk url from  {url}!")
        # we want to get the smallest apk, which is arm64-v8a
        path = match.group(1).replace("-android/", "-android-arm64-v8a/")
        if path.endswith(".apk"):
            return f"{base_url}{path}"


def update_config(base_path, url):
    yaml = ruamel.yaml.YAML()
    yaml.indent(mapping=2, sequence=4, offset=2)
    yaml.width = 150
    yaml.preserve_quotes = True

    config_path = base_path / "projects/browser/config"
    config_name = "fenix-nightly-apk"
    config = yaml.load(config_path)

    for input_file in config["input_files"]:
        if input_file.get("name") == config_name:
            apk_file_path = base_path / "out/browser" / url.split("/")[-1]
            if url == input_file["URL"]:
                if apk_file_path.exists():
                    print(f"{apk_file_path} exists, checking hash...")
                    sha256 = hashlib.sha256()
                    with apk_file_path.open("rb") as f:
                        while chunk := f.read(16384):
                            sha256.update(chunk)
                    sha256sum = sha256.hexdigest()
                    if sha256sum == input_file["sha256sum"]:
                        print(f"{config_name}/URL is up-to-date, nothing to do.")
                        return False
            sha256sum = download_apk(url, apk_file_path)
            input_file["sha256sum"] = sha256sum
            input_file["URL"] = url
            with config_path.open("w") as f:
                yaml.dump(config, f)
                print(f"Updated input_files/{config_name} in {config_path}.")
            return True
    raise Exception(f"Cannot find input_files/{config_name} in {config_path}!")


def download_apk(url, dest):
    print(f"Downloading {url} to {dest}....")
    r = requests.get(url, stream=True)
    r.raise_for_status()
    sha256 = hashlib.sha256()
    with dest.open("wb") as f:
        for chunk in r.iter_content(chunk_size=8192):
            f.write(chunk)
            sha256.update(chunk)
    return sha256.hexdigest()


def update_fenix_nightly_apk(base_path):
    url = find_apk_url()
    return update_config(base_path, url)


if __name__ == "__main__":
    update_fenix_nightly_apk(Path(__file__).parent.parent)
