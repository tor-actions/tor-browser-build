<details>
  <summary>Explanation of variables</summary>

- `$(BUILD_SERVER)` : the server the main builder is using to build a mullvad-browser release
- `$(STAGING_SERVER)` : the server the signer is using to to run the signing process
- `$(ESR_VERSION)` : the Mozilla defined ESR version, used in various places for building mullvad-browser tags, labels, etc
  - example : `91.6.0`
- `$(MULLVAD_BROWSER_MAJOR)` : the Mullvad Browser major version
  - example : `11`
- `$(MULLVAD_BROWSER_MINOR)` : the Mullvad Browser minor version
  - example : either `0` or `5`; Alpha's is always `(Stable + 5) % 10`
- `$(MULLVAD_BROWSER_VERSION)` : the Mullvad Browser version in the format
  - example: `12.5a3`, `12.0.3`
- `$(BUILD_N)` : a project's build revision within a its branch; this is separate from the `$(MULLVAD_BROWSER_BUILD_N)` value; many of the Firefox-related projects have a `$(BUILD_N)` suffix and may differ between projects even when they contribute to the same build.
    - example : `build1`
- `$(MULLVAD_BROWSER_BUILD_N)` : the mullvad-browser build revision for a given Mullvad Browser release; used in tagging git commits
    - example : `build2`
    - **NOTE** : A project's `$(BUILD_N)` and `$(MULLVAD_BROWSER_BUILD_N)` may be the same, but it is possible for them to diverge. For example :
        - if we have multiple Mullvad Browser releases on a given ESR branch the two will become out of sync as the `$(BUILD_N)` value will increase, while the `$(MULLVAD_BROWSER_BUILD_N)` value may stay at `build1` (but the `$(MULLVAD_BROWSER_VERSION)` will increase)
        - if we have build failures unrelated to `mullvad-browser`, the `$(MULLVAD_BROWSER_BUILD_N)` value will increase while the `$(BUILD_N)` will stay the same.
- `$(MULLVAD_BROWSER_VERSION)` : the published Mullvad Browser version
    - example : `11.5a6`, `11.0.7`
</details>

**NOTE** It is assumed that the `tor-browser` rebase and security backport tasks have been completed

<details>
  <summary>Build Configs</summary>

### tor-browser-build: https://gitlab.mullvadproject.org/tpo/applications/tor-browser-build.git
Mullvad Browser Stable lives in the various `maint-$(MULLVAD_BROWSER_MAJOR).$(MULLVAD_BROWSER_MINOR)` (and possibly more specific) branches

- [ ] Update `rbm.conf`
  - [ ] `var/torbrowser_version` : update to next version
  - [ ] `var/torbrowser_build` : update to `$(MULLVAD_BROWSER_BUILD_N)`
  - [ ] `var/torbrowser_incremental_from` : update to previous Desktop version
    - **IMPORTANT**: Really *actually* make sure this is the previous Desktop version or else the `make mullvadbrowser-incrementals-*` step will fail
- [ ] Update build configs
  - [ ] Update `projects/firefox/config`
    - [ ] `git_hash` : update the `$(BUILD_N)` section to match `mullvad-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] Update `projects/translation/config`:
    - [ ] run `make list_translation_updates-release` to get updated hashes
    - [ ] `steps/base-browser/git_hash` : update with `HEAD` commit of project's `base-browser` branch
    - [ ] `steps/base-browser-fluent/git_hash` : update with `HEAD` commit of project's `basebrowser-newidentityftl` branch
- [ ] Update common build configs
  - [ ] Check for NoScript updates here : https://addons.mozilla.org/en-US/firefox/addon/noscript
    - [ ] ***(Optional)*** If new version available, update `noscript` section of `input_files` in `projects/browser/config`
      - [ ] `URL`
      - [ ] `sha256sum`
  - [ ] Check for uBlock-origin updates here : https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
    - [ ] ***(Optional)*** If new version available, update `ublock-origin` section of `input_files` in `projects/browser/config`
      - [ ] `URL`
      - [ ] `sha256sum`
  - [ ] Check for Mullvad Privacy Companion updates here : https://github.com/mullvad/browser-extension/releases
    - [ ] ***(Optional)*** If new version available, update `mullvad-extension` section of `input_files` in `projects/browser/config`
      - [ ] `URL`
      - [ ] `sha256sum`
- [ ] Open MR with above changes
- [ ] Begin build on `$(BUILD_SERVER)` (and fix any issues which come up and update MR)
- [ ] Merge
- [ ] Sign/Tag commit: `make mullvadbrowser-signtag-release`
- [ ] Push tag to `origin`

</details>

<details>
  <summary>Signing</summary>

### signing + publishing
- [ ] Ensure builders have matching builds
- [ ] On `$(STAGING_SERVER)`, ensure updated:
  - [ ] `tor-browser-build/tools/signing/set-config`
    - `NSS_DB_DIR` : location of the `nssdb7` direcmullvady
  - [ ]  `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_builder` : ssh hostname of machine with unsigned builds
      - **NOTE** : `tor-browser-build` is expected to be in the `$HOME` direcmullvady)
    - `ssh_host_linux_signer` : ssh hostname of linux signing machine
    - `ssh_host_macos_signer` : ssh hostname of macOS signing machine
  - [ ] `tor-browser-build/tools/signing/set-config.macos-notarization`
    - `macos_notarization_user` : the email login for a mullvad notariser Apple Developer account
  - [ ] `set-config.update-responses`
    - `update_responses_reposimullvady_dir` : direcmullvady where you cloned `git@gitlab.mullvadproject.org:tpo/applications/mullvad-browser-update-responses.git`
  - [ ] `tor-browser-build/tools/signing/set-config.tbb-version`
    - `tbb_version` : mullvad browser version string, same as `var/torbrowser_version` in `rbm.conf` (examples: `11.5a12`, `11.0.13`)
    - `tbb_version_build` : the tor-browser-build build number (if `var/torbrowser_build` in `rbm.conf` is `buildN` then this value is `N`)
    - `tbb_version_type` : either `alpha` for alpha releases or `release` for stable releases
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, run the macOS proxy script:
    - `cd tor-browser-build/tools/signing/`
    - `./macos-signer-proxy`
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, ensure mullvad daemon is running with SOCKS5 proxy on the default port 9050
- [ ] apk signing : copy signed `*multi.apk` files to the unsigned build outputs direcmullvady
- [ ] run do-all-signing script:
    - `cd tor-browser-build/tools/signing/`
    - `./do-all-signing.sh`
- **NOTE**: at this point the signed binaries should be in `tor-browser-build/mullvadbrowser/release/signed/$(MULLVAD_BROWSER_VERSION)`

</details>

<details>
  <summary>Communications</summary>

### notify stakeholders

- [ ] Email Mullvad with release information: rui@mullvad.net
  - [ ] Build artifact download list
  - [ ] New `mullvad-browser` project branch and tags
  - [ ] mullvad-browser-update-responses git hash
  - [ ] changelog

</details>



/label ~"Release Prep"
