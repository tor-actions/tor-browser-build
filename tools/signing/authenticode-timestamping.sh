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

osslsigncode_file="$script_dir/../../out/osslsigncode/osslsigncode-d6f94d71f731-62e185.tar.gz"

test -f "$osslsigncode_file" ||
  exit_error "$osslsigncode_file is missing." \
             "You can build it with:" \
             "  ./rbm/rbm build osslsigncode" \
             "See var/deps in projects/osslsigncode/config for the list of build dependencies"

which rename > /dev/null 2>&1 ||
  exit_error '`rename` is missing.'

tmp_dir="$signed_dir/$tbb_version/tmp-timestamp"
mkdir "$tmp_dir"
tar -C "$tmp_dir" -xf "$osslsigncode_file"
export PATH="$PATH:$tmp_dir/osslsigncode/bin"

cd "$signed_dir/$tbb_version"
COUNT=0
for i in `find . -name "*.exe" -print`
do
  osslsigncode add \
                 -t http://timestamp.digicert.com \
                 -p socks://127.0.0.1:9050 \
                 $i $i-timestamped
  COUNT=$((COUNT + 1))

done
echo "Timestamped $COUNT .exe files, now renaming"
rename -f 's/-timestamped//' *-timestamped

rm -Rf "$tmp_dir"
