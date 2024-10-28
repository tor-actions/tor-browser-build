## Related Issues

- tor-browser-build#xxxxx
- tor-browser-build#xxxxx

## Self-review + reviewer's template

- [ ] `rbm.conf` updates:
  - [ ] `var/torbrowser_version`
  - [ ] `var/torbrowser_build`: should be `build1`, unless bumping a previous release preparation
  - [ ] `var/browser_release_date`: must not be in the future when we start building
  - [ ] `var/torbrowser_incremental_from` (not needed for Android-only releases)
  - [ ] `var/torbrowser_legacy_version` (For Tor Browser 14.0.x stable releases only)
  - [ ] `var/torbrowser_legacy_platform_version` (For Tor Browser 14.0.x stable releases only)
- [ ] Tag updates:
  - [ ] [Firefox](https://gitlab.torproject.org/tpo/applications/tor-browser/-/tags)
  - [ ] Geckoview - should match Firefox
  - Tags might be speculative in the release preparation: i.e., they might not exist yet.
- [ ] Addon updates:
  - [ ] [NoScript](https://addons.mozilla.org/en-US/firefox/addon/noscript/)
  - [ ] [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/) (Mullvad Browser only)
  - [ ] [Mullvad Browser Extension](https://github.com/mullvad/browser-extension/releases) (Mullvad Browser only)
  - For AMO extension (NoScript and uBlock), updating the version in the URL is not enough, check that also a numeric ID from the URL has changed
- [ ] Tor and dependencies updates (Tor Browser only)
  - [ ] [Tor](https://gitlab.torproject.org/tpo/core/tor/-/tags)
  - [ ] [OpenSSL](https://www.openssl.org/source/): we stay on the latest LTS channel (currently 3.0.x)
  - [ ] [zlib](https://github.com/madler/zlib/releases)
  - [ ] [Zstandard](https://github.com/facebook/zstd/releases) (Android only, at least for now)
  - [ ] [Go](https://go.dev/dl): avoid major updates, unless planned
- [ ] Manual version update (Tor Browser only, optional)
- [ ] Changelogs
  - [ ] Changelogs must be in sync between stable and alpha
  - [ ] Check the browser name
  - [ ] Check the version
  - [ ] Check the release date
  - [ ] Check we include only the platform we're releasing for (e.g., no Android in desktop-only releases)
  - [ ] Check all the updates from above are reported in the changelogs
  - [ ] Check for major errors
    - If you find errors such as platform or category (build system) please adjust the issue label accordingly
    - You can run `tools/relprep.py --only-changelogs --date $date $version` to update only the changelogs

## Review

### Request Reviewer

- [ ] Request review from a release engineer: boklm, dan, ma1, morgan, pierov

### Change Description

