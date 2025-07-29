#!/bin/bash

# This script is called from gatekeeper-bundling.sh, and creates a dmg
# file from a directory
#
# Usage:
#   ddmg.sh <dmg-file> <src-directory> <Volume Label> <release date>

set -e

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/functions"

dest_file="$1"
src_dir="$2"
volume_label="$3"
browser_release_date="$4"

set +e
find $src_dir -executable -exec chmod 0755 {} \; 2> /dev/null
find $src_dir ! -executable -exec chmod 0644 {} \; 2> /dev/null

find $src_dir -exec touch -m -t 200001010101 {} \; 2> /dev/null
set -e

dmg_tmpdir=$(mktemp -d)
hfsfile="$dmg_tmpdir/tbb-uncompressed.dmg"

export LD_PRELOAD=$faketime_path
export FAKETIME="$browser_release_date"

echo "Starting: " $(basename $dest_file)

# 1 for ceiling and 1 for the inode
fileblocks=$(find "$src_dir" -type f -printf '%s\n' | awk '{s += int($1 / 4096) + 2} END {print s}')
directories=$(find "$src_dir" -type d | wc -l)
# Give some room to breathe
size=$(echo $(($fileblocks + $directories)) | awk '{print int($1 * 1.1)}')
dd if=/dev/zero of="$hfsfile" bs=4096 count=$size
newfs_hfs -v "$volume_label" "$hfsfile"

cd $src_dir

# hfsplus does not play well with dangling links, so remove /Applications, and
# add it back again with the special command to do so.
rm -f Applications

find -type d -mindepth 1 | sed -e 's/^\.\///' | sort | while read dirname; do
  hfsplus "$hfsfile" mkdir "/$dirname"
  hfsplus "$hfsfile" chmod 0755 "/$dirname"
done
find -type f | sed -e 's/^\.\///' | sort | while read filename; do
  hfsplus "$hfsfile" add "$filename" "/$filename"
  hfsplus "$hfsfile" chmod $(stat --format '0%a' "$filename") "/$filename"
done
hfsplus "$hfsfile" symlink /Applications /Applications
# Show the volume icon
hfsplus "$hfsfile" attr / C

dmg dmg --compression lzma --level 5 --run-sectors 2048 "$hfsfile" "$dest_file"

echo "Finished: " $(basename $dest_file)

rm -Rf "$dmg_tmpdir"
