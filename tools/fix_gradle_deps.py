#!/usr/bin/env python3
import hashlib
from pathlib import Path
import os
import re
import shutil
import sys
from urllib.parse import urlparse

import requests


# maven.mozilla.org does not work over IPv6 from our build servers.
# See https://gitlab.torproject.org/tpo/tpa/team/-/issues/41654.
requests.packages.urllib3.util.connection.HAS_IPV6 = False

if len(sys.argv) < 3:
    print(
        f"Usage: {sys.argv[0]} project-name gradle-dep-num"
    )
    sys.exit(1)
target = sys.argv[1]
target_ver = sys.argv[2]
# We assume the script is in tor-browser-build/tools
tbbuild = Path(__file__).parent.parent

java_projects = sorted([
    txt.parent.name for txt in tbbuild.glob("projects/**/gradle-dependencies-list.txt")
])

existing = {}
for p in java_projects:
    p = tbbuild / "out" / p
    for gd in p.glob("gradle-dependencies-*"):
        for fname in gd.glob("**/*"):
            if fname.is_file():
                existing[fname.relative_to(gd)] = fname

parser = re.compile(r"^([0-9a-fA-F]+)\s+\|\s+(\S+)\s*$")
pairs = []
with open(tbbuild / "projects" / target / "gradle-dependencies-list.txt") as f:
    for line in f.readlines():
        line = line.strip()
        if line[0] == '#' or line == 'sha256sum | url':
            continue
        m = parser.match(line)
        pairs.append((m.group(2), m.group(1)))

dest_dir = tbbuild / "out" / target / f"gradle-dependencies-{target_ver}"
dest_dir.mkdir(parents=True, exist_ok=True)
os.chdir(str(dest_dir))

hashes = {}
poms = set()

for u, h in pairs:
    p = Path(urlparse(u).path[1:])
    if not p.exists():
        p.parent.mkdir(parents=True, exist_ok=True)
        if p in existing:
            print(f"Copying {p} from {existing[p]}")
            shutil.copyfile(existing[p], p)
        else:
            print(f"Downloading {u}")
            r = requests.get(u)
            r.raise_for_status()
            with p.open("wb") as f:
                f.write(r.content)

    if p.suffix != ".pom":
        m = hashlib.sha256()
        with p.open("rb") as f:
            m.update(f.read())
        if m.hexdigest() != h:
            print("Hash mismatch!", u)
        elif h in hashes:
            print("Duplicated item!", h, hashes[h].name, p)
        else:
            hashes[h] = p
    else:
        if p in poms:
            print(f"Duplicated pom: {p}")
        else:
            poms.add(p)
