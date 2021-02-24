#!/bin/bash

# This script allows you to repackage a Tor Browser bundle using an
# obj-x86_64-pc-linux-gnu directory from a local tor-browser.git build.
#
# This script will download the current Tor Browser version (using
# var/torbrowser_version from rbm config, or an optional second argument)
# and repackage it with the specified obj directory.
#
# The new repackaged bundle can be found in the _repackaged directory.

set -e

display_usage() {
	echo -e "\\nUsage: $0 firefox_obj_path [torbrowser-version]\\n"
}
if [ $# -lt 1 ] || [ $# -gt 2 ]
then
    display_usage
    exit 1
fi

DIRNAME="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
OBJ_PATH=$1
if [ $# -eq 2 ]
then
  TOR_VERSION="$2"
else
  TOR_VERSION=$("$DIRNAME"/../rbm/rbm showconf tor-browser var/torbrowser_version)
fi
TOR_FILENAME=tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz
TOR_BROWSER_URL=https://dist.torproject.org/torbrowser/"${TOR_VERSION}"/"${TOR_FILENAME}"
TMPDIR="$(mktemp -d)"

(
cd "$TMPDIR"
wget "$TOR_BROWSER_URL"
wget "$TOR_BROWSER_URL".asc
gpg --no-default-keyring --keyring "$DIRNAME"/../keyring/torbrowser.gpg --verify "${TOR_FILENAME}".asc "${TOR_FILENAME}"

# From projects/firefox/build: replace firefox binary by the wrapper and strip libraries/binaries
tar xf "${TOR_FILENAME}"
cp -r "${OBJ_PATH}"/dist/firefox .
rm firefox/firefox-bin
mv firefox/firefox firefox/firefox.real
for LIB in firefox/*.so firefox/gtk2/*.so firefox/firefox.real firefox/plugin-container firefox/updater
do
    strip "$LIB"
done

# Repackage https-everywhere extension
mkdir _omni/
unzip tor-browser_en-US/Browser/omni.ja -d _omni/
cd _omni/
zip -Xmr ../firefox/omni.ja chrome/torbutton/content/extensions/https-everywhere/
cd ..
rm -rf _omni/

# Overwrite extracted tor-browser with locally built files and move to _repackaged folder
cp -r firefox/* tor-browser_en-US/Browser
rm -rf firefox "${TOR_FILENAME}"
REPACKAGED_DIR="$DIRNAME"/_repackaged/
mkdir -p "$REPACKAGED_DIR"
mv tor-browser_en-US "$REPACKAGED_DIR"/tor-browser-"$(date '+%Y%m%d%H%M%S')"
rm -rf "$TMPDIR"
)
