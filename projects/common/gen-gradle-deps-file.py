#!/usr/bin/env python3

import argparse
import hashlib
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed


def download_and_hash(url):
    try:
        sha256_hash = hashlib.sha256()
        with urllib.request.urlopen(url) as f:
            sha256_hash.update(f.read())
        return url, sha256_hash.hexdigest(), None
    except Exception as e:
        return url, None, str(e)


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="""
This script generates a `gradle-dependencies-list.txt` file as expected by
Tor Browser Build to download dependencies for offline builds.

It parses a log file from a Gradle build, determines which dependencies were
downloaded and from where, re-downloads them, and calculates their SHA256 hash.
Downloads are parallelized — by default, 4 workers are used, but this can be
configured via the optional `--workers` argument.

---

Usage:

First, run the exact Gradle command that will be used inside the offline
tor-browser-build container. Make sure to set the log level to `info` and
capture the full output to a log file.

`--refresh-dependencies` can be pass to Gradle to force all dependencies to be
re-downloaded if needed (e.g., if running this script outside containers or
outside tor-browser-build).

Example:

    ./gradlew --info clean assembleRelease 2>&1 | tee -a out.log

Then run this script with the generated log:

    ./gen-gradle-deps-file.py out.log

This will create a `gradle-dependencies-list.txt` file in the current
directory.
""",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "log_file", help="Path to the Gradle log file (e.g., out.log)"
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=4,
        help="Number of parallel download workers (default: 4).",
    )
    parser.add_argument(
        "--output",
        default="gradle-dependencies-list.txt",
        help="Output file path (default: gradle-dependencies-list.txt).",
    )

    return parser.parse_args()


def extract_urls(log_file):
    pattern = re.compile(rf"Downloading (https://\S+) to ")
    urls = []
    with open(log_file, "r") as file:
        for line in file:
            match = pattern.search(line.strip())
            if match:
                urls.append(match.group(1))
    return urls


def main():
    args = parse_arguments()

    urls = extract_urls(args.log_file)
    if not urls:
        print("⚠️ No matching download lines found in the log file.")
        return

    print(
        f"🔍 Found {len(urls)} URLs. Starting downloads using {args.workers} workers...\n"
    )

    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {
            executor.submit(download_and_hash, url): url for url in urls
        }
        for future in as_completed(futures):
            url, sha256, error = future.result()
            if error:
                print(f"[ERROR] {url}\n  Reason: {error}")
            else:
                print(f"[OK] {url}\n  SHA256: {sha256}")
                results.append((sha256, url))

    if results:
        with open(args.output, "w") as out_file:
            out_file.write(
                "# Don't forget to update var/gradle_dependencies_version when modifying this file\n"
            )
            out_file.write("sha256sum | url\n")
            for sha256, url in sorted(results, key=lambda x: x[1]):
                out_file.write(f"{sha256} | {url}\n")
        print(f"\n✅ {len(urls)} dependencies written to: {args.output}")
    else:
        print("\n⚠️ No successful downloads to write.")
        sys.exit(1)


if __name__ == "__main__":
    main()
