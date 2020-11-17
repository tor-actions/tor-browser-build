#!/bin/sh

# Copyright (c) 2021, The Tor Project, Inc.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
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

# Usage:
# 1) Let OSSLSIGNCODE point to your osslsigncode binary
# 2) Change into the directory containing the .exe files and the sha256sums-unsigned-build.txt
# 3) Run /path/to/authenticode_verify_timestamp.sh

if [ -z "$OSSLSIGNCODE" ]
then
  echo "The path to your osslsigncode binary is missing!"
  exit 1
fi

#set -x

VERIFIED_PACKAGES=0
MISSING_TIMESTAMP=0

for f in `ls *.exe`; do
  echo -n "$f timestamped: "

  ${OSSLSIGNCODE} extract-signature -pem -in $f -out $f.sigs 1>/dev/null
  ts=`openssl pkcs7 -print -in $f.sigs | grep -A 227 unauth_attr`
  ts_len=`openssl pkcs7 -print -in $f.sigs | grep -A 227 unauth_attr | wc -l`
  rm $f.sigs

  if [ $ts_len -ne 228 ]; then
    echo "timestamp format changed. Expected 228 lines, but received $ts_len"
  fi

  missing_attrs=0
  # Random selection. We can choose better ones later.
  for exp in "d=1 hl=2 l= 9 prim: OBJECT :pkcs7-signedData" \
             "d=4 hl=2 l= 11 prim: OBJECT :id-smime-ct-TSTInfo" \
             "d=9 hl=2 l= 40 prim: PRINTABLESTRING :DigiCert SHA2 Assured ID Timestamping CA" \
             "d=9 hl=2 l= 23 prim: PRINTABLESTRING :DigiCert Timestamp 2021" \
             "d=7 hl=2 l= 9 prim: OBJECT :signingTime"; do
    #echo "Checking '$exp'"
    if ! `echo $ts | grep -q "$exp"`; then
      missing_attrs=`expr $missing_attrs + 1`
      echo "no: missing attribute: $exp"
    fi
  done
  if [ $missing_attrs -ne 0 ]; then
    MISSING_TIMESTAMP=`expr $MISSING_TIMESTAMP + 1`
  else
    echo yes
  fi

  CHECKED_PACKAGES=`expr ${CHECKED_PACKAGES} + 1`
done

if [ "${MISSING_TIMESTAMP}" -ne 0 ]; then
  echo "${MISSING_TIMESTAMP} packages not timestamped."
  exit 1
fi

if [ "${CHECKED_PACKAGES}" -ne `ls *.exe | wc -l` ]; then
  echo "Some packages were not verified!."
  exit 1
fi

echo "Successfully verified are ${CHECKED_PACKAGES} timestamped"

exit 0
