#!/usr/bin/env python3

# Sets these keys in a property list file:
#   CFBundleGetInfoString
#   CFBundleShortVersionString
#   NSHumanReadableCopyright

import getopt
import plistlib
import sys


def usage():
    print(
        f"Usage: {sys.argv[0]} plist-file product-name version year copyright-holder",
        file=sys.stderr,
    )
    sys.exit(2)


_, args = getopt.gnu_getopt(sys.argv[1:], "")

if len(args) != 5:
    usage()

fname = args[0]
product = args[1]
version = args[2]
year = args[3]
holder = args[4]

copyright = f"{product} {version} Copyright {year} {holder}"

with open(fname, "rb") as f:
    plist = plistlib.load(f)

plist["CFBundleGetInfoString"] = f"{product} {version}"
plist["CFBundleShortVersionString"] = version
plist["NSHumanReadableCopyright"] = copyright

with open(fname, "wb") as f:
    plistlib.dump(plist, f)
