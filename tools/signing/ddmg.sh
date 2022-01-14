#!/bin/bash

# This script is called from gatekeeper-bundling.sh, and creates a dmg
# file from a directory
#
# Usage:
#   ddmg.sh <dmg-file> <src-directory>

set -e

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/functions"

dest_file="$1"
src_dir="$2"

set +e
find $src_dir -executable -exec chmod 0755 {} \; 2> /dev/null
find $src_dir ! -executable -exec chmod 0644 {} \; 2> /dev/null

find $src_dir -exec touch -m -t 200001010101 {} \; 2> /dev/null
set -e

dmg_tmpdir=$(mktemp -d)
filelist="$dmg_tmpdir/filelist.txt"
cd $src_dir
find . -type f | sed -e 's/^\.\///' | sort | xargs -i echo "{}={}" > $filelist
find . -type l | sed -e 's/^\.\///' | sort | xargs -i echo "{}={}" >> $filelist

export LD_PRELOAD=$faketime_path
export FAKETIME="2000-01-01 01:01:01"

echo "Starting: " $(basename $dest_file)

genisoimage -D -V "Tor Browser" -no-pad -R -apple -o "$dmg_tmpdir/tbb-uncompressed.dmg" -path-list $filelist -graft-points -gid 20 -dir-mode 0755 -new-dir-mode 0755

dmg dmg "$dmg_tmpdir/tbb-uncompressed.dmg" "$dest_file"

echo "Finished: " $(basename $dest_file)

rm -Rf "$dmg_tmpdir"
