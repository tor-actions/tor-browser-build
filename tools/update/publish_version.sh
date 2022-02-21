#!/bin/bash

set -e

TORBROWSER_VERSION=$1
if [ -z "${TORBROWSER_VERSION}" ]; then
    echo "please specify version number (excluding -buildN)"
	exit 1
fi

PREV_TORBROWSER_VERSION=$2
if [ -z "${PREV_TORBROWSER_VERSION}" ]; then
    echo "please specify a previous version number (needed for copying .htaccess file)"
	exit 1
fi

wget --continue -nH --cut-dirs=2 -r -l 1 "https://people.torproject.org/~sysrqb/builds/${TORBROWSER_VERSION}"
#wget --continue -nH --cut-dirs=2 -r -l 1 "https://people.torproject.org/~gk/builds/${TORBROWSER_VERSION}"
rm "${TORBROWSER_VERSION}/index.html*"

date
mv "${TORBROWSER_VERSION}" /srv/dist-master.torproject.org/htdocs/torbrowser/
cp "/srv/dist-master.torproject.org/htdocs/torbrowser/${PREV_TORBROWSER_VERSION}/.htaccess" "/srv/dist-master.torproject.org/htdocs/torbrowser/${TORBROWSER_VERSION}/"
chmod 775 "/srv/dist-master.torproject.org/htdocs/torbrowser/${TORBROWSER_VERSION}"
chmod 664 "/srv/dist-master.torproject.org/htdocs/torbrowser/${TORBROWSER_VERSION}"/*
chown -R :torwww "/srv/dist-master.torproject.org/htdocs/torbrowser/${TORBROWSER_VERSION}"
cd "/srv/dist-master.torproject.org/htdocs/torbrowser/${TORBROWSER_VERSION}"
for i in *.asc; do echo "$i"; gpg -q "$i" || exit; done
date
static-update-component dist.torproject.org

mkdir "/srv/cdn-master.torproject.org/htdocs/aus1/torbrowser/${TORBROWSER_VERSION}"
chmod 775 "/srv/cdn-master.torproject.org/htdocs/aus1/torbrowser/${TORBROWSER_VERSION}"
cd "/srv/cdn-master.torproject.org/htdocs/aus1/torbrowser/${TORBROWSER_VERSION}"
for marfile in /srv/dist-master.torproject.org/htdocs/torbrowser/"${TORBROWSER_VERSION}"/*.mar; do ln -f "${marfile}" .; done
date
static-update-component cdn.torproject.org

echo "Now sync and publish update responses"
