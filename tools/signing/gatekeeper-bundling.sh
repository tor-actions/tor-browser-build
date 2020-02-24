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

TORBROWSER_VERSION=$1
if [ -z $TORBROWSER_VERSION ];
then
  echo "Please call this script with a Tor Browser version!"
  exit 1
fi
BUNDLE_LOCALES="ar ca cs da de el en-US es-AR es-ES fa fr ga-IE he hu id is it ja ka ko mk nb-NO nl pl pt-BR ro ru sv-SE tr vi zh-CN zh-TW"
builddir=/path/to/the/build/dir
mkdir $builddir/$TORBROWSER_VERSION-signed
for LANG in $BUNDLE_LOCALES
do
  cd $builddir/dmg
  unzip -q $builddir/$TORBROWSER_VERSION/tb-${TORBROWSER_VERSION}_$LANG-stapled.zip
  cd ..
  $builddir/ddmg.sh $builddir/$TORBROWSER_VERSION-signed/TorBrowser-${TORBROWSER_VERSION}-osx64_$LANG.dmg $builddir/dmg/
  rm -rf 'dmg/Tor Browser.app'
done