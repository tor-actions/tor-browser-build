#!/usr/bin/env python3
import argparse
from collections import OrderedDict
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("recommended_transport")
parser.add_argument("platform")
parser.add_argument("dest", type=Path)
args = parser.parse_args()

pt_path = ""
pt_extension = ""
if args.platform == "linux":
    pt_path = "./TorBrowser/Tor/PluggableTransports/"
elif args.platform == "macos":
    pt_path = "PluggableTransports/"
elif args.platform == "windows":
    pt_path = "TorBrowser\\Tor\\PluggableTransports\\"
    pt_extension = ".exe"

pt_lines = OrderedDict()
with open("transports.json") as f:
    transports = json.load(f, object_pairs_hook=OrderedDict)
for key, defs in transports.items():
    defs["path"] = (
        defs["path"]
        .replace("${pt_path}", pt_path)
        .replace("${pt_extension}", pt_extension)
    )
    protocols = ",".join(defs["protocols"])
    arguments = " ".join(defs.get("arguments", []))
    if arguments:
        arguments = " " + arguments
    pt_lines[key] = (
        f'ClientTransportPlugin {protocols} exec {defs["path"]}{arguments}'
    )

with open("builtin.json") as f:
    bridges = json.load(f, object_pairs_hook=OrderedDict)

output = OrderedDict()
output["recommendedDefault"] = args.recommended_transport
output["transports"] = transports
output["pluggableTransports"] = pt_lines
output["bridges"] = bridges

with (args.dest / "tor/pluggable_transports/pt_config.json").open("w") as f:
    json.dump(output, f, indent=2)
with (args.dest / "data/torrc-defaults").open("a+") as f:
    for line in pt_lines.values():
        f.write(line + "\n")
