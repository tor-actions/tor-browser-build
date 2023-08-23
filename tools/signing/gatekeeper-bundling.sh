#!/bin/bash

# Copyright (c) 2019, The Tor Project, Inc.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:

#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#
#     * Neither the names of the copyright owners nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/functions"

test -f $faketime_path || \
  exit_error "$faketime_path is missing"
test -d $macos_stapled_dir || \
  exit_error "The stapled macos zip files should be placed in directory $macos_stapled_dir"
libdmg_file="$script_dir/../../out/libdmg-hfsplus/libdmg-hfsplus-2ee327795680-555a7e.tar.gz"
test -f "$libdmg_file" || \
  exit_error "$libdmg_file is missing." \
             "You can build it with:" \
             "  ./rbm/rbm build --target no_containers libdmg-hfsplus" \
             "See var/deps in projects/libdmg-hfsplus/config for the list of build dependencies"
hfstools_file="$script_dir/../../out/hfsplus-tools/hfsplus-tools-540.1.linux3-81ff5b.tar.gz"
test -f "$hfstools_file" || \
  exit_error "$hfstools_file is missing." \
             "You can build it with:" \
             "  ./rbm/rbm build --target no_containers hfsplus-tools" \
             "You will need the clang and uuid-dev packages installed"

ProjName=$(ProjectName)
Proj_Name=$(Project_Name)
proj_name=$(project-name)

test -d "$macos_signed_dir" || mkdir "$macos_signed_dir"
tmpdir="$macos_stapled_dir/tmp"
rm -Rf "$tmpdir"
mkdir "$tmpdir"
cp -rT "$script_dir/../../projects/browser/Bundle-Data/$ProjName.dmg" "$tmpdir/dmg"

tar -C "$tmpdir" -xf "$libdmg_file"
tar -C "$tmpdir" -xf "$hfstools_file"
export PATH="$PATH:$tmpdir/libdmg-hfsplus:$tmpdir/hfsplus-tools"

for lang in $bundle_locales
do
  cd $tmpdir/dmg
  unzip -q $macos_stapled_dir/tb-${tbb_version}_$lang-stapled.zip
  cd ..
  $script_dir/ddmg.sh $macos_signed_dir/${proj_name}-macos-${tbb_version}.dmg $tmpdir/dmg/ "$Proj_Name"
  rm -rf "dmg/$Proj_Name.app"
done
rm -Rf "$tmpdir"

# move the signed+stapled dmgs to expected output directory for publishing and mar generation
mv -vf "$macos_signed_dir"/"${proj_name}"-*.dmg "$signed_version_dir"/
