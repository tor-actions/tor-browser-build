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

**NOTE** It is assumed that the `tor-browser` stable rebase and security backport tasks have been completed

**NOTE** This can/is often done in conjunction with the equivalent Tor Browser release prep issue

<details>
  <summary>Building</summary>

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Mullvad Browser Stable lives in the various `maint-$(MULLVAD_BROWSER_MAJOR).$(MULLVAD_BROWSER_MINOR)` (and possibly more specific) branches

- [ ] Update `rbm.conf`
  - [ ] `var/torbrowser_version` : update to next version
  - [ ] `var/torbrowser_build` : update to `$(MULLVAD_BROWSER_BUILD_N)`
  - [ ] `var/browser_release_date` : update to build date. For the build to be reproducible, the date should be in the past when building.
  - [ ] `var/torbrowser_incremental_from` : update to previous Desktop version
    - **NOTE**: We try to build incrementals for the previous 3 desktop versions except in the case of a watershed update
    - **IMPORTANT**: Really *actually* make sure this is the previous Desktop version or else the `make mullvadbrowser-incrementals-*` step will fail
- [ ] Update build configs
  - [ ] Update `projects/firefox/config`
    - [ ] `browser_build` : update to match `mullvad-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] Update `projects/translation/config`:
    - [ ] run `make list_translation_updates-release` to get updated hashes
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
  - [ ] Check for Mullvad Browser Extension updates here : https://github.com/mullvad/browser-extension/releases
    - [ ] ***(Optional)*** If new version available, update `mullvad-extension` section of `input_files` in `projects/browser/config`
      - [ ] `URL`
      - [ ] `sha256sum`
- [ ] Update `ChangeLog-MB.txt`
  - [ ] Ensure `ChangeLog-MB.txt` is sync'd between alpha and stable branches
  - [ ] Check the linked issues: ask people to check if any are missing, remove the not fixed ones
  - [ ] Run `./tools/fetch-changelogs.py $(ISSUE_NUMBER) --date $date $updateArgs`
    - Make sure you have `requests` installed (e.g., `apt install python3-requests`)
    - The first time you run this script you will need to generate an access token; the script will guide you
    - `$updateArgs` should be these arguments, depending on what you actually updated:
      - [ ] `--firefox` (be sure to include esr at the end if needed, which is usually the case)
      - [ ] `--no-script`
      - [ ] `--ublock`
      - E.g., `./tools/fetch-changelogs.py 41029 --date 'December 19 2023' --firefox 115.6.0esr --no-script 11.4.29 --ublock 1.54.0`
    - `--date $date` is optional, if omitted it will be the date on which you run the command
  - [ ] Copy the output of the script to the beginning of `ChangeLog-MB.txt` and adjust its output
- [ ] Open MR with above changes, using the template for release preparations
- [ ] Merge
- [ ] Sign+Tag
  - **NOTE** this must be done by one of:
    - boklm
    - dan
    - ma1
    - pierov
    - richard
  - [ ] Run: `make mullvadbrowser-signtag-release`
  - [ ] Push tag to `upstream`
- [ ] Build the tag:
  - Run `make mullvadbrowser-release && make mullvadbrowser-incrementals-release`
    - [ ] Tor Project build machine
    - [ ] Local developer machine
  - [ ] Submit build request to Mullvad infrastructure:
    - **NOTE** this requires a devmole authentication token
    - Run `make mullvadbrowser-kick-devmole-build`
- [ ] Ensure builders have matching builds

</details>

<details>
  <summary>Signing</summary>

### release signing
- [ ] Assign this issue to the signer, one of:
  - boklm
  - richard
- [ ] On `$(STAGING_SERVER)`, ensure updated:
  - [ ] `tor-browser-build` is on the right commit: `git tag -v tbb-$(MULLVAD_BROWSER_VERSION)-$(MULLVAD_BROWSER_BUILD_N) && git checkout tbb-$(MULLVAD_BROWSER_VERSION)-$(MULLVAD_BROWSER_BUILD_N)`
  - [ ]  `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_builder` : ssh hostname of machine with unsigned builds
      - **NOTE** : `tor-browser-build` is expected to be in the `$HOME` directory)
    - `ssh_host_linux_signer` : ssh hostname of linux signing machine
  - [ ] `tor-browser-build/tools/signing/set-config.rcodesign-appstoreconnect`
    - `appstoreconnect_api_key_path` : path to json file containing appstoreconnect api key infos
  - [ ] `set-config.update-responses`
    - `update_responses_repository_dir` : directory where you cloned `git@gitlab.torproject.org:tpo/applications/mullvad-browser-update-responses.git`
  - [ ] `tor-browser-build/tools/signing/set-config.tbb-version`
    - `tbb_version` : mullvad browser version string, same as `var/torbrowser_version` in `rbm.conf` (examples: `11.5a12`, `11.0.13`)
    - `tbb_version_build` : the tor-browser-build build number (if `var/torbrowser_build` in `rbm.conf` is `buildN` then this value is `N`)
    - `tbb_version_type` : either `alpha` for alpha releases or `release` for stable releases
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, ensure tor daemon is running with SOCKS5 proxy on the default port 9050
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, run do-all-signing script:
  - `cd tor-browser-build/tools/signing/`
  - `./do-all-signing.mullvadbrowser`
- **NOTE**: at this point the signed binaries should have been copied to `staticiforme`
- [ ] Update `staticiforme.torproject.org`:
  - From `screen` session on `staticiforme.torproject.org`:
  - [ ] Remove old release data from `/srv/dist-master.torproject.org/htdocs/mullvadbrowser`
  - [ ] Static update components (again) : `static-update-component dist.torproject.org`

</details>

<details>
  <summary>Publishing</summary>

### mullvad-browser (GitHub): https://github.com/mullvad/mullvad-browser/
- [ ] Assign this issue to someone with mullvad commit access, one of:
    - boklm
    - ma1
    - richard
    - pierov
- [ ] Push this release's associated `mullvad-browser.git` branch to github
- [ ] Push this release's associated tags to github:
  - [ ] Firefox ESR tag
    - **example** : `FIREFOX_102_12_0esr_BUILD1`
  - [ ] `base-browser` tag
    - **example** : `base-browser-102.12.0esr-12.0-1-build1`
  - [ ] `mullvad-browser` tag
    - **example** : `mullvad-browser-102.12.0esr-12.0-1-build1`
- [ ] Sign+Tag additionally the `mullvad-browser.git` `firefox` commit used in build:
  - **Tag**: `$(MULLVAD_BROWSER_VERSION)`
    - **example** : `12.0.7`
  - **Message**: `$(ESR_VERSION)esr-based $(MULLVAD_BROWSER_VERSION)`
    - **example** : `102.12.0esr-based 12.0.7`
  - [ ] Push tag to github

### email
- [ ] **(Once branch+tags pushed to GitHub)** Email Mullvad with release information:
  - [ ] support alias: support@mullvadvpn.net
  - [ ] Rui: rui@mullvad.net
  - **Subject**
    ```
    New build: Mullvad Browser $(MULLVAD_BROWSER_VERION) (signed)
    ```
  - **Body**
    ```
    Hello,

    Branch+Tags have been pushed to Mullvad's GitHub repo.

    - signed builds: https://dist.torproject.org/mullvadbrowser/$(MULLVAD_BROWSER_VERSION)
    - update_response hashes: $(MULLVAD_UPDATE_RESPONSES_HASH)

    changelog:
    ...
    ```

</details>

<details>
  <summary>Downstream</summary>

### notify packagers
These steps depend on Mullvad having updated their [GitHub Releases](https://github.com/mullvad/mullvad-browser/releases/) page with the latest release
- [ ] Email downstream consumers:
  - [ ] flathub package maintainer: proletarius101@protonmail.com
  - [ ] arch package maintainer: bootctl@gmail.com
  - [ ] nixOS package maintainer: dev@felschr.com
  - **Subject**
    ```
    Mullvad Browser $(MULLVAD_BROWSER_VERSION) released
    ```
  - **Body**
    ```
    Hello!

    Mullvad-Browser packages are available, so you should update your respective downstream packages.

    The latest release builds can be found here:

    - https://github.com/mullvad/mullvad-browser/releases?q=prerelease%3Afalse
    ```

### merge requests
- [ ] homebrew: https://github.com/Homebrew/homebrew-cask/blob/master/Casks/m/mullvad-browser.rb
  - **NOTE**: should just need to update `version` and `sha256` to latest

</details>

/label ~"Release Prep"
/label  ~"Sponsor 131"

