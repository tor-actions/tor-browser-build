#!/usr/bin/env python3

import urllib.request
import json
import base64
import sys

NOSCRIPT = "{73a6fe31-595d-460b-a920-fcc0f8843232}"


def fetch(x):
    with urllib.request.urlopen(x) as response:
        return response.read()


def find_addon(addons, addon_id):
    results = addons["results"]
    for x in results:
        addon = x["addon"]
        if addon["guid"] == addon_id:
            return addon


def fetch_and_embed_icons(addons):
    results = addons["results"]
    for x in results:
        addon = x["addon"]
        icon_data = fetch(addon["icon_url"])
        addon["icon_url"] = "data:image/png;base64," + str(
            base64.b64encode(icon_data), "utf8"
        )


def fetch_allowed_addons(amo_collection=None):
    if amo_collection is None:
        amo_collection = "83a9cccfe6e24a34bd7b155ff9ee32"
    url = f"https://services.addons.mozilla.org/api/v4/accounts/account/mozilla/collections/{amo_collection}/addons/"
    data = json.loads(fetch(url))
    fetch_and_embed_icons(data)
    data["results"].sort(key=lambda x: x["addon"]["guid"])
    return data


def main(argv):
    data = fetch_allowed_addons(argv[0] if len(argv) > 1 else None)
    # Check that NoScript is present
    if find_addon(data, NOSCRIPT) is None:
        sys.exit("Error: cannot find NoScript.")
    print(json.dumps(data, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main(sys.argv[1:])
