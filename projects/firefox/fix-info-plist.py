#!/usr/bin/env python3

# Sets these keys in a property list file:
#   CFBundleGetInfoString
#   CFBundleShortVersionString
#   NSHumanReadableCopyright

import getopt
import plistlib
import sys

def usage():
    print("usage: %s TORBROWSER_VERSION YEAR < Info.plist > FixedInfo.plist" % sys.argv[0], file=sys.stderr)
    sys.exit(2)

_, args = getopt.gnu_getopt(sys.argv[1:], "")

if len(args) != 2:
    usage()

TORBROWSER_VERSION = args[0]
YEAR = args[1]

COPYRIGHT = "Tor Browser %s Copyright %s The Tor Project" % (TORBROWSER_VERSION, YEAR)

sys.stdin = open(sys.stdin.fileno(), 'rb')
plist = plistlib.load(sys.stdin)

plist["CFBundleGetInfoString"] = "Tor Browser %s" % TORBROWSER_VERSION
plist["CFBundleShortVersionString"] = TORBROWSER_VERSION
plist["NSHumanReadableCopyright"] = COPYRIGHT

sys.stdout = open(sys.stdout.fileno(), 'wb')
plistlib.dump(plist, sys.stdout)
