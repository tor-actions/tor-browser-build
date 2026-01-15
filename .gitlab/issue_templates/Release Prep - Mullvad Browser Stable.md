# Release Prep Mullvad Browser Stable

- **NOTE** It is assumed the `mullvad-browser` release rebase and security backport tasks have been completed
- **NOTE** This can/is often done in conjunction with the equivalent Tor Browser release prep issue

<details>
  <summary>Explanation of variables</summary>

- `${BUILD_SERVER}`: the server the main builder is using to build a browser release
- `${BUILDER}`: whomever is building the release on the ${BUILD_SERVER}
  - **example**: `pierov`
- `${STAGING_SERVER}`: the server the signer is using to to run the signing process
- `${ESR_VERSION}`: the Mozilla defined ESR version, used in various places for building browser tags, labels, etc
  - **example**: `91.6.0`
- `${MULLVAD_BROWSER_MAJOR}`: the Mullvad Browser major version
  - **example**: `11`
- `${MULLVAD_BROWSER_MINOR}`: the Mullvad Browser minor version
  - **example**: either `0` or `5`; Alpha's is always `(Stable + 5) % 10`
- `${MULLVAD_BROWSER_VERSION}`: the Mullvad Browser version in the format
  - **example**: `12.5a3`, `12.0.3`
- `${BUILD_N}`: a project's build revision within a its branch; this is separate from the `${MULLVAD_BROWSER_BUILD_N}` value; many of the Firefox-related projects have a `${BUILD_N}` suffix and may differ between projects even when they contribute to the same build.
  - **example**: `build1`
- `${MULLVAD_BROWSER_BUILD_N}`: the mullvad-browser build revision for a given Mullvad Browser release; used in tagging git commits
  - **example**: `build2`
    - **⚠️ WARNING**: A project's `${BUILD_N}` and `${MULLVAD_BROWSER_BUILD_N}` may be the same, but it is possible for them to diverge. For **example** :
      - if we have multiple Mullvad Browser releases on a given ESR branch the two will become out of sync as the `${BUILD_N}` value will increase, while the `${MULLVAD_BROWSER_BUILD_N}` value may stay at `build1` (but the `${MULLVAD_BROWSER_VERSION}` will increase)
      - if we have build failures unrelated to `mullvad-browser`, the `${MULLVAD_BROWSER_BUILD_N}` value will increase while the `${BUILD_N}` will stay the same.
- `${MULLVAD_BROWSER_VERSION}`: the published Mullvad Browser version
    - **example**: `11.5a6`, `11.0.7`
- `${MB_BUILD_TAG}`: the `tor-browser-build` build tag used to build a given Mullvad Browser version
   - **example**: `mb-12.0.7-build1`
- `${RELEASE_DATE}`: the intended release date of this browser release; for ESR schedule-driven releases, this should match the upstream Firefox release date
  - **example**: `2024-10-29`

</details>

<details>
  <summary>Build Configuration</summary>

### mullvad-browser: https://gitlab.torproject.org/tpo/applications/mullvad-browser.git

- [ ] Tag `mullvad-browser` commit:
  - **example**: `mullvad-browser-128.3.0esr-14.0-1-build1`
  - Run:
    ```bash
    ./tools/browser/sign-tag.mullvadbrowser stable ${BUILD_N}
    ```

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Mullvad Browser Stable is on the `maint-${MULLVAD_BROWSER_MAJOR}.${MULLVAD_BROWSER_MINOR}` branch

- [ ] Changelog bookkeeping:
  - Ensure all commits to `mullvad-browser` and `tor-browser-build` for this release have an associated issue linked to this release preparation issue
  - Ensure each issue has a platform (~Windows, ~MacOS, ~Linux, ~Desktop, ~"All Platforms") and potentially ~"Build System" labels
- [ ] Create a release preparation branch from the current `maint-XX.Y` branch
- [ ] Run release preparation script:
  - **NOTE**: You can omit the `--mullvad-browser` argument if this is for a joint Tor and Mullvad Browser release
  - **⚠️ WARNING**: You may need to manually update the `firefox/config` file's `browser_build` field if `mullvad-browser.git` has not yet been tagged (e.g. if security backports have not yet been merged and tagged)
  ```bash
  ./tools/relprep.py --mullvad-browser --date ${RELEASE_DATE} ${MULLVAD_BROWSER_VERSION}
  ```
- [ ] Review build configuration changes:
  - [ ] `rbm.conf`
    - [ ] `var/torbrowser_version`: updated to next browser version
    - [ ] `var/torbrowser_build`: updated to `${MULLVAD_BROWSER_BUILD_N}`
    - [ ] `var/browser_release_date`: updated to build date. For the build to be reproducible, the date should be in the past when building.
      - **⚠️ WARNING**: If we have updated `var/torbrowser_build` without updating the `firefox` tag, then we can leave this unchanged to avoid forcing a firefox re-build (e.g. when bumping `var/torbrowser_build` to build2, build3, etc due to non-firefox related build issues)
    - [ ] `var/torbrowser_incremental_from`: updated to previous Desktop version
      - **NOTE**: We try to build incrementals for the previous 3 desktop versions
      - **⚠️ WARNING**: Really *actually* make sure this is the previous Desktop version or else the `make mullvadbrowser-incrementals-*` step will fail
  - [ ] `projects/firefox/config`
    - [ ] `var/browser_build`: updated to match `mullvad-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version`: updated to latest `${ESR_VERSION}` if rebased
  - [ ] ***(Optional)*** `projects/translation/config`:
    - [ ] `steps/base-browser/git_hash`: updated with `HEAD` commit of project's `base-browser` branch
    - [ ] `steps/mullvad-browser/git_hash`: updated with `HEAD` commit of project's `mullvad-browser` branch
  - [ ] ***(Optional)*** `projects/browser/config`:
    - [ ] ***(Optional)*** NoScript: https://addons.mozilla.org/en-US/firefox/addon/noscript
      - [ ] `URL` updated
        - **⚠️ WARNING**: If preparing the release manually, updating the version number in the url is not sufficient, as each version has a random unique id in the download url
      - [ ] `sha256sum` updated
    - [ ] ***(Optional)*** uBlock-origin: https://addons.mozilla.org/en-US/firefox/addon/ublock-origin
      - [ ] `URL` updated
        - **⚠️ WARNING**: If preparing the release manually, updating the version number in the url is not sufficient, as each version has a random unique id in the download url
      - [ ] `sha256sum` updated
    - [ ] ***(Optional)*** Mullvad Browser extension: https://github.com/mullvad/browser-extension/releases
      - [ ] `URL` updated
      - [ ] `sha256sum` updated
  - [ ] `ChangeLog-MB.txt`: ensure correctness
    - Browser name correct
    - Release date correct
    - No Android updates
    - All issues added under correct platform
    - ESR updates correct
    - Component updates correct
- [ ] Open MR with above changes, using the template for release preparations
  - **NOTE**: target the `maint-14.5` branch
- [ ] Merge
- [ ] Sign+Tag
  - **NOTE** this must be done by one of:
    - boklm
    - dan
    - ma1
    - morgan
    - pierov
  - Run:
    ```bash
    make mullvadbrowser-signtag-release
    ```
- [ ] Push tag to `upstream`
- [ ] Build the tag:
  - Run:
    ```bash
    make mullvadbrowser-release && make mullvadbrowser-incrementals-release
    ```
    - [ ] Tor Project build machine
    - [ ] Local developer machine
  - [ ] Submit build request to Mullvad infrastructure:
    - **NOTE** this requires a github authentication token
    - Run:
      ```bash
      make mullvadbrowser-kick-devmole-build
      ```

</details>

<details>
  <summary>Signing</summary>

### release signing
- [ ] Assign this issue to the signer, one of:
  - boklm
  - ma1
  - morgan
  - pierov
- [ ] Ensure all builders have matching builds
- [ ] On `${STAGING_SERVER}`, ensure updated:
  - **NOTE** Having a local git branch with `maint-14.5` as the upstream branch with these values saved means you only need to periodically `git pull --rebase` and update the `set-config.tbb-version` file
  - [ ] `tor-browser-build` is on the right commit: `git tag -v mb-${MULLVAD_BROWSER_VERSION}-${MULLVAD_BROWSER_BUILD_N} && git checkout mb-${MULLVAD_BROWSER_VERSION}-${MULLVAD_BROWSER_BUILD_N}`
  - [ ] `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_builder`: ssh hostname of machine with unsigned builds
    - `ssh_host_linux_signer`: ssh hostname of linux signing machine
    - `builder_tor_browser_build_dir`: path on `ssh_host_builder` to root of builder's `tor-browser-build` clone containing unsigned builds
  - [ ] `tor-browser-build/tools/signing/set-config.rcodesign-appstoreconnect`
    - `appstoreconnect_api_key_path`: path to json file containing appstoreconnect api key infos
  - [ ] `set-config.update-responses`
    - `update_responses_repository_dir`: directory where you cloned `git@gitlab.torproject.org:tpo/applications/mullvad-browser-update-responses.git`
  - [ ] `tor-browser-build/tools/signing/set-config.tbb-version`
    - `tbb_version`: mullvad browser version string, same as `var/torbrowser_version` in `rbm.conf` (examples: `11.5a12`, `11.0.13`)
    - `tbb_version_build`: the tor-browser-build build number (if `var/torbrowser_build` in `rbm.conf` is `buildN` then this value is `N`)
    - `tbb_version_type`: either `alpha` for alpha releases or `release` for stable releases
- [ ] On `${STAGING_SERVER}` in a separate `screen` session, ensure tor daemon is running with SOCKS5 proxy on the default port 9050
- [ ] On `${STAGING_SERVER}` in a separate `screen` session, run do-all-signing script:
  - Run:
    ```bash
    cd tor-browser-build/tools/signing/ && ./do-all-signing.mullvadbrowser
    ```
  - **NOTE**: on successful execution, the signed binaries and mars should have been copied to `staticiforme` and update responses pushed

</details>

<details>
  <summary>Publishing</summary>

### website
- [ ] On `staticiforme.torproject.org`, remove old release and publish new:
  - [ ] `/srv/dist-master.torproject.org/htdocs/mullvadbrowser`
  - Run:
    ```bash
    static-update-component dist.torproject.org
    ```

### mullvad-browser (GitHub): https://github.com/mullvad/mullvad-browser/
This step will send the relevant branches, tags (including a tag named after the release version, e.g. `15.0`) and the signed build for QA to Mullvad's github repository.
- [ ] Assign this issue to someone with mullvad commit access, one of:
    - boklm
    - ma1
    - morgan
    - pierov
- [ ] Run:
    ```bash
    cd tor-browser-build/tools/signing/ && ./publish-github.mullvadbrowser
    ```
  - **NOTE**: if you need the release version tag to be suffixed someway, e.g. because it's a release candidate (`15.0rc1` instead of `15.0`), just add the fix as the first argument of the script:
     ```bash
     ./publish-github.mullvadbrowser rc1
     ```
</details>

<details>
  <summary>Communications</summary>

### packagers

- [ ] **(Once Packages are pushed to GitHub)**
  - **Recipients**
    - flathub package maintainer: proletarius101@protonmail.com
    - arch package maintainer: bootctl@gmail.com
    - nixOS package maintainer: dev@felschr.com
    ```
    proletarius101@protonmail.com, bootctl@gmail.com, dev@felschr.com,
    ```
  - **Subject**
    ```
    Mullvad Browser ${MULLVAD_BROWSER_VERSION} released
    ```
  - **Body**
    ```
    Hello!

    Mullvad-Browser packages are available, so you should update your respective downstream packages.

    The latest release builds can be found here:

    - https://github.com/mullvad/mullvad-browser/releases?q=prerelease%3Afalse
    ```

### merge requests
- [ ] **(Once Packages are pushed to GitHub)**
  - [ ] homebrew: https://github.com/Homebrew/homebrew-cask/blob/master/Casks/m/mullvad-browser.rb
    - **NOTE**: a bot seems to pick this up without needing our intervention these days
    - **NOTE**: should just need to update `version` and `sha256` to latest

</details>

/label ~"Apps::Type::ReleasePreparation"
/label ~"Apps::Product::MullvadBrowser"
/label ~"Apps::Impact::High"
/label ~"Priority::Blocker"
/label ~"Project 196"
