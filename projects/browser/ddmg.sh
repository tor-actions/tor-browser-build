#!/bin/bash
set -e

[% SET src = c('dmg_src', { error_if_undef => 1 }) -%]
find [% src %] -executable -exec chmod 0755 {} \;
find [% src %] ! -executable -exec chmod 0644 {} \;

find [% src %] -exec [% c("touch") %] {} \;

dmg_tmpdir=\$(mktemp -d)
hfsfile="\$dmg_tmpdir/tbb-uncompressed.dmg"

# hfsplus sets all the times to time(NULL)
export LD_PRELOAD=[% c("var/faketime_path") %]
export FAKETIME="[% USE date; GET date.format(c('timestamp'), format = '%Y-%m-%d %H:%M:%S') %]"

# Use a similar strategy to Mozilla (they have 1.02, we have 1.1)
size=\$(du -ms [% src %] | awk '{ print int( \$1 * 1.1 ) }')
dd if=/dev/zero of="\$hfsfile" bs=1M count=\$size
newfs_hfs -v "[% c("var/Project_Name") %]" "\$hfsfile"

pushd [% src %]

find -type d -mindepth 1 | sed -e 's/^\.\///' | sort | while read dirname; do
  hfsplus "\$hfsfile" mkdir "/\$dirname"
  hfsplus "\$hfsfile" chmod 0755 "/\$dirname"
done
find -type f | sed -e 's/^\.\///' | sort | while read filename; do
  hfsplus "\$hfsfile" add "\$filename" "/\$filename"
  hfsplus "\$hfsfile" chmod \$(stat --format '0%a' "\$filename") "/\$filename"
done
# hfsplus does not play well with dangling links
hfsplus "\$hfsfile" symlink /Applications /Applications
# Show the volume icon
hfsplus "\$hfsfile" attr / C

dmg dmg "\$hfsfile" [% c('dmg_out', { error_if_undef => 1 }) %]
popd

rm -Rf "\$dmg_tmpdir"
