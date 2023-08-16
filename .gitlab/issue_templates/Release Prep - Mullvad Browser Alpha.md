<details>
  <summary>Explanation of variables</summary>

- `$(BUILD_SERVER)` : the server the main builder is using to build a mullvad-browser release
- `$(BUILDER)` : whomever is building the release on the $(BUILD_SERVER)
  - **example** : `pierov`
- `$(STAGING_SERVER)` : the server the signer is using to to run the signing process
- `$(ESR_VERSION)` : the Mozilla defined ESR version, used in various places for building mullvad-browser tags, labels, etc
  - **example** : `91.6.0`
- `$(MULLVAD_BROWSER_MAJOR)` : the Mullvad Browser major version
  - **example** : `11`
- `$(MULLVAD_BROWSER_MINOR)` : the Mullvad Browser minor version
  - **example** : either `0` or `5`; Alpha's is always `(Stable + 5) % 10`
- `$(MULLVAD_BROWSER_VERSION)` : the Mullvad Browser version in the format
  - **example** : `12.5a3`, `12.0.3`
- `$(BUILD_N)` : a project's build revision within a its branch; this is separate from the `$(MULLVAD_BROWSER_BUILD_N)` value; many of the Firefox-related projects have a `$(BUILD_N)` suffix and may differ between projects even when they contribute to the same build.
    - **example** : `build1`
- `$(MULLVAD_BROWSER_BUILD_N)` : the mullvad-browser build revision for a given Mullvad Browser release; used in tagging git commits
    - **example** : `build2`
    - **NOTE** : A project's `$(BUILD_N)` and `$(MULLVAD_BROWSER_BUILD_N)` may be the same, but it is possible for them to diverge. For **example** :
      - if we have multiple Mullvad Browser releases on a given ESR branch the two will become out of sync as the `$(BUILD_N)` value will increase, while the `$(MULLVAD_BROWSER_BUILD_N)` value may stay at `build1` (but the `$(MULLVAD_BROWSER_VERSION)` will increase)
      - if we have build failures unrelated to `mullvad-browser`, the `$(MULLVAD_BROWSER_BUILD_N)` value will increase while the `$(BUILD_N)` will stay the same.
- `$(MULLVAD_BROWSER_VERSION)` : the published Mullvad Browser version
    - **example** : `11.5a6`, `11.0.7`
- `$(MB_BUILD_TAG)` : the `tor-browser-build` build tag used to build a given Mullvad Browser version
    - **example** : `mb-12.0.7-build1`
</details>

**NOTE** It is assumed that the `tor-browser` alpha rebase and security backport tasks have been completed

<details>
  <summary>Building</summary>

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Mullvad Browser Alpha (and Nightly) are on the `main` branch

- [ ] Update `rbm.conf`
  - [ ] `var/torbrowser_version` : update to next version
  - [ ] `var/torbrowser_build` : update to `$(MULLVAD_BROWSER_BUILD_N)`
  - [ ] `var/torbrowser_incremental_from` : update to previous Desktop version
    - **IMPORTANT**: Really *actually* make sure this is the previous Desktop version or else the `make mullvadbrowser-incrementals-*` step will fail
- [ ] Update build configs
  - [ ] Update `projects/firefox/config`
    - [ ] `browser_build` : update to match `mullvad-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] Update `projects/translation/config`:
    - [ ] run `make list_translation_updates-alpha` to get updated hashes
    - [ ] `steps/base-browser/git_hash` : update with `HEAD` commit of project's `base-browser` branch
    - [ ] `steps/mullvad-browser/git_hash` : update with `HEAD` commit of project's `mullvad-browser` branch
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
- [ ] Merge
- [ ] Sign/Tag commit: `make mullvadbrowser-signtag-alpha`
- [ ] Push tag to `origin`
- [ ] Begin build on `$(BUILD_SERVER)` (fix any issues in subsequent MRs)
- [ ] **TODO** Submit build-tag to Mullvad build infra
- [ ] Ensure builders have matching builds

</details>

<details>
  <summary>QA</summary>

### send the build

  - [ ] Email Mullvad QA: support@mullvad.net, rui@mullvad.net
    <details>
      <summary>email template</summary>

        Subject:
        New build: Mullvad Browser $(MULLVAD_BROWSER_VERION) (unsigned)

        Body:
        unsigned builds: https://tb-build-05.torproject.org/~$(BUILDER)/builds/mullvadbrowser/release/unsigned/$(MB_BUILD_TAG)

        changelog:
        ...

    </details>

    - ***(Optional)*** Add additional information:
      - [ ] Note any new functionality which needs testing
      - [ ] Link to any known issues

</details>

<details>
  <summary>Signing</summary>

### signing
- [ ] On `$(STAGING_SERVER)`, ensure updated:
  - [ ]  `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_builder` : ssh hostname of machine with unsigned builds
      - **NOTE** : `tor-browser-build` is expected to be in the `$HOME` directory)
    - `ssh_host_linux_signer` : ssh hostname of linux signing machine
    - `ssh_host_macos_signer` : ssh hostname of macOS signing machine
  - [ ] `tor-browser-build/tools/signing/set-config.macos-notarization`
    - `macos_notarization_user` : the email login for a mullvad notariser Apple Developer account
  - [ ] `set-config.update-responses`
    - `update_responses_repository_dir` : directory where you cloned `git@gitlab.torproject.org:tpo/applications/mullvad-browser-update-responses.git`
  - [ ] `tor-browser-build/tools/signing/set-config.tbb-version`
    - `tbb_version` : mullvad browser version string, same as `var/torbrowser_version` in `rbm.conf` (examples: `11.5a12`, `11.0.13`)
    - `tbb_version_build` : the tor-browser-build build number (if `var/torbrowser_build` in `rbm.conf` is `buildN` then this value is `N`)
    - `tbb_version_type` : either `alpha` for alpha releases or `release` for stable releases
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, run the macOS proxy script:
    - `cd tor-browser-build/tools/signing/`
    - `./macos-signer-proxy`
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, ensure tor daemon is running with SOCKS5 proxy on the default port 9050
- [ ] run do-all-signing script:
    - `cd tor-browser-build/tools/signing/`
    - `./do-all-signing.mullvadbrowser`
- **NOTE**: at this point the signed binaries should have been copied to `staticiforme`
- [ ] Update `staticiforme.torproject.org`:
  - From `screen` session on `staticiforme.torproject.org`:
  - [ ] Static update components : `static-update-component dist.torproject.org`
  - [ ] Remove old release data from `/srv/dist-master.torproject.org/htdocs/mullvadbrowser`
  - [ ] Static update components (again) : `static-update-component dist.torproject.org`

</details>

<details>
  <summary>Publishing</summary>

### email

- [ ] Email Mullvad with release information: support@mullvad.net, rui@mullvad.net
  <details>
    <summary>email template</summary>

      Subject:
      New build: Mullvad Browser $(MULLVAD_BROWSER_VERION) (signed)

      Body:
      signed builds: https://dist.torproject.org/mullvadbrowser/$(MULLVAD_BROWSER_VERSION)

      update_response hashes: $(MULLVAD_UPDATE_RESPONSES_HASH)

      changelog:
      ...

  </details>

### mullvad-browser (github): https://github.com/mullvad/mullvad-browser/
- [ ] Push this release's associated `mullvad-browser.git` branch to github
- [ ] Push this release's associated tags to github:
  - [ ] Firefox ESR tag
    - **example** : `FIREFOX_102_12_0esr_BUILD1,`
  - [ ] `base-browser` tag
    - **example** : `base-browser-102.12.0esr-12.0-1-build1`
  - [ ] `mullvad-browser` tag
    - **example** : `mullvad-browser-102.12.0esr-12.0-1-build1`
- [ ] Sign+Tag additionally the `mullvad-browser.git` `firefox` commit used in build:
  - **Tag**: `$(MULLVAD_BROWSER_VERSION)`
    - **example** : `12.5a7`
  - **Message**: `$(ESR_VERSION)esr-based $(MULLVAD_BROWSER_VERSION)`
    - **example** : `102.12.0esr-based 12.5a7`
  - [ ] Push tag to github

</details>

<details>
  <summary>Downstream</summary>

### notify packagers

- [ ] **(Optional, Once Mullvad Updates their Github Releases Page)** Email downstream consumers:
  <details>
    <summary>email template</summary>

    ...

    ...

  </details>

  - **NOTE**: This is an optional step and only necessary close a major release/transition from alpha to stable, or if there are major packing changes these developers need to be aware of
  - [ ] flathub package maintainer: proletarius101@protonmail.com
  - [ ] arch package maintainer: bootctl@gmail.com
  - [ ] nixOS package maintainer: dev@felschr.com

</details>

/label ~"Release Prep"
