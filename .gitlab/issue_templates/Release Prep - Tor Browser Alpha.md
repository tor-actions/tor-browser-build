<details>
  <summary>Explanation of variables</summary>

- `$(BUILD_SERVER)` : the server the main builder is using to build a tor-browser release
- `$(BUILDER)` : whomever is building the release on the $(BUILD_SERVER)
  - **example** : `pierov`
- `$(STAGING_SERVER)` : the server the signer is using to to run the signing process
- `$(ESR_VERSION)` : the Mozilla defined ESR version, used in various places for building tor-browser tags, labels, etc
  - **example** : `91.6.0`
- `$(TOR_BROWSER_MAJOR)` : the Tor Browser major version
  - **example** : `11`
- `$(TOR_BROWSER_MINOR)` : the Tor Browser minor version
  - **example** : either `0` or `5`; Alpha's is always `(Stable + 5) % 10`
- `$(TOR_BROWSER_VERSION)` : the Tor Browser version in the format
  - **example** : `12.5a3`, `12.0.3`
- `$(BUILD_N)` : a project's build revision within a its branch; this is separate from the `$(TOR_BROWSER_BUILD_N)` value; many of the Firefox-related projects have a `$(BUILD_N)` suffix and may differ between projects even when they contribute to the same build.
  - **example** : `build1`
- `$(TOR_BROWSER_BUILD_N)` : the tor-browser build revision for a given Tor Browser release; used in tagging git commits
  - **example** : `build2`
  - **NOTE** : A project's `$(BUILD_N)` and `$(TOR_BROWSER_BUILD_N)` may be the same, but it is possible for them to diverge. For example :
    - if we have multiple Tor Browser releases on a given ESR branch the two will become out of sync as the `$(BUILD_N)` value will increase, while the `$(TOR_BROWSER_BUILD_N)` value may stay at `build1` (but the `$(TOR_BROWSER_VERSION)` will increase)
    - if we have build failures unrelated to `tor-browser`, the `$(TOR_BROWSER_BUILD_N)` value will increase while the `$(BUILD_N)` will stay the same.
- `$(TOR_BROWSER_VERSION)` : the published Tor Browser version
    - **example** : `11.5a6`, `11.0.7`
- `$(TBB_BUILD_TAG)` : the `tor-browser-build` build tag used to build a given Tor Browser version
    - **example** : `tbb-12.5a7-build1`
</details>

**NOTE** It is assumed that the `tor-browser` stable rebase and security backport tasks have been completed
**NOTE** This can/is often done in conjunction with the equivalent Mullvad Browser release prep issue

<details>
  <summary>Building</summary>

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Tor Browser Alpha (and Nightly) are on the `main` branch

- [ ] Update `rbm.conf`
  - [ ] `var/torbrowser_version` : update to next version
  - [ ] `var/torbrowser_build` : update to `$(TOR_BROWSER_BUILD_N)`
  - [ ] ***(Desktop Only)***`var/torbrowser_incremental_from` : update to previous Desktop version
    - **NOTE**: We try to build incrementals for the previous 3 desktop versions except in the case of a watershed update
    - **IMPORTANT**: Really *actually* make sure this is the previous Desktop version or else the `make torbrowser-incrementals-*` step will fail
- [ ] Update Desktop-specific build configs
  - [ ] Update `projects/firefox/config`
    - [ ] `browser_build` : update to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest `$(ESR_VERSION)` if rebased
- [ ] Update Android-specific build configs
  - [ ] Update `projects/geckoview/config`
    - [ ] `browser_build` : update to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/geckoview_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] ***(Optional)*** Update `projects/tor-android-service/config`
    - [ ] `git_hash` : update with `HEAD` commit of project's `main` branch
  - [ ] ***(Optional)*** Update `projects/application-services/config`:
    **NOTE** we don't currently have any of our own patches for this project
    - [ ] `git_hash` : update to appropriate git commit associated with `$(ESR_VERSION)`
  - [ ] ***(Optional)*** Update `projects/firefox-android/config`:
    - [ ] `fenix_version` : update to match alpha `firefox-android` build tag
    - [ ] `browser_branch` : update to match alpha `firefox-android` build tag
    - [ ] `browser_build` : update to match alpha `firefox-android` build tag
  - [ ] Update allowed_addons.json by running (from `tor-browser-build` root):
    - `./tools/fetch_allowed_addons.py > projects/browser/allowed_addons.json`
- [ ] Update `projects/translation/config`:
  - [ ] run `make list_translation_updates-alpha` to get updated hashes
  - [ ] `steps/base-browser/git_hash` : update with `HEAD` commit of project's `base-browser` branch
  - [ ] `steps/tor-browser/git_hash` : update with `HEAD` commit of project's `tor-browser` branch
  - [ ] `steps/fenix/git_hash` : update with `HEAD` commit of project's `fenix-torbrowserstringsxml` branch
- [ ] Update common build configs
  - [ ] Check for NoScript updates here : https://addons.mozilla.org/en-US/firefox/addon/noscript
    - [ ] ***(Optional)*** If new version available, update `noscript` section of `input_files` in `projects/browser/config`
      - [ ] `URL`
      - [ ] `sha256sum`
  - [ ] Check for OpenSSL updates here : https://www.openssl.org/source/
    - [ ] ***(Optional)*** If new 3.0.X version available, update `projects/openssl/config`
      - [ ] `version` : update to next 3.0.X version
      - [ ] `input_files/sha256sum` : update to sha256 sum of source tarball
  - [ ] Check for zlib updates here: https://github.com/madler/zlib/releases
    - [ ] **(Optional)** If new tag available, update `projects/zlib/config`
      - [ ] `version` : update to next release tag
  - [ ] Check for tor updates here : https://gitlab.torproject.org/tpo/core/tor/-/tags
    - [ ] ***(Optional)*** Update `projects/tor/config`
      - [ ] `version` : update to latest `-alpha` tag or release tag if newer (ping dgoulet or ahf if unsure)
  - [ ] Check for go updates here : https://go.dev/dl
    - **NOTE** : In general, Tor Browser Alpha uses the latest Stable major series Go version, but there are sometimes exceptions. Check with the anti-censorship team before doing a major version update in case there is incompatibilities.
    - [ ] ***(Optional)*** Update `projects/go/config`
      - [ ] `version` : update go version
      - [ ] `input_files/sha256sum` for `go` : update sha256sum of archive (sha256 sums are displayed on the go download page)
  - [ ] Check for manual updates by running (from `tor-browser-build` root): `./tools/fetch-manual.py`
    - [ ] ***(Optional)*** If new version is available:
      - [ ] Upload the downloaded `manual_$PIPELINEID.zip` file to `tb-build-02.torproject.org`
      - [ ] Deploy to `tb-builder`'s `public_html` directory:
        - `sudo -u tb-builder cp manual_$PIPELINEID.zip ~tb-builder/public_html/.`
      - [ ] Update `projects/manual/config`:
        - [ ] Change the `version` to `$PIPELINEID`
        - [ ] Update `sha256sum` in the `input_files` section
- [ ] Update `ChangeLog-TBB.txt`
  - [ ] Ensure `ChangeLog-TBB.txt` is sync'd between alpha and stable branches
  - [ ] Check the linked issues: ask people to check if any are missing, remove the not fixed ones
  - [ ] Run `./tools/fetch-changelogs.py $(ISSUE_NUMBER) --date $date $updateArgs`
    - Make sure you have `requests` installed (e.g., `apt install python3-requests`)
    - The first time you run this script you will need to generate an access token; the script will guide you
    - `$updateArgs` should be these arguments, depending on what you actually updated:
      - [ ] `--firefox` (be sure to include esr at the end if needed, which is usually the case)
      - [ ] `--tor`
      - [ ] `--no-script`
      - [ ] `--openssl`
      - [ ] `--zlib`
      - [ ] `--go`
      - E.g., `./tools/fetch-changelogs.py 41028 --date 'December 19 2023' --firefox 115.6.0esr --tor 0.4.8.10 --no-script 11.4.29 --zlib 1.3 --go 1.21.5 --openssl 3.0.12`
    - `--date $date` is optional, if omitted it will be the date on which you run the command
  - [ ] Copy the output of the script to the beginning of `ChangeLog-TBB.txt` and adjust its output
- [ ] Open MR with above changes, using the template for release preparations
- [ ] Merge
- [ ] Sign+Tag
  - **NOTE** this must be done by one of:
    - boklm
    - dan
    - ma1
    - pierov
    - richard
  - [ ] Run: `make torbrowser-signtag-alpha`
  - [ ] Push tag to `upstream`
- [ ] Build the tag:
  - Run `make torbrowser-alpha && make torbrowser-incrementals-alpha`
    - [ ] Tor Project build machine
    - [ ] Local developer machine
  - [ ] Submit build request to Mullvad infrastructure:
    - **NOTE** this requires a devmole authentication token
    - Run `make torbrowser-kick-devmole-build`
- [ ] Ensure builders have matching builds

</details>

<details>
  <summary>Communications</summary>

### notify stakeholders
- [ ] **(Once builds confirmed matching)** Email tor-qa mailing list with release information
  - [ ] tor-qa: tor-qa@lists.torproject.org
  - **Subject**
    ```
    Tor Browser $(TOR_BROWSER_VERION) (Android, Windows, macOS, Linux)
    ```
  - **Body**
    ```
    Hello,

    Unsigned Tor Browser $(TOR_BROWSER_VERSION) alpha candidate builds are now available for testing:

    - https://tb-build-02.torproject.org/~$(BUILDER)/builds/torbrowser/alpha/unsigned/$(TOR_BROWSER_VERSION)/

    The full changelog can be found here:

    - https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/raw/$(TBB_BUILD_TAG)/projects/browser/Bundle-Data/Docs-TBB/ChangeLog.txt
    ```
- [ ] ***(Optional, only around build/packaging changes)*** Email packagers:
  - [ ] Tails dev mailing list: tails-dev@boum.org
  - [ ] Guardian Project: nathan@guardianproject.info
  - [ ] FreeBSD port: freebsd@sysctl.cz <!-- Gitlab user maxfx -->
  - [ ] OpenBSD port: caspar@schutijser.com <!-- Gitlab user cschutijser -->
  - [ ] Note any changes which may affect packaging/downstream integration
- [ ] ***(Optional, after ESR migration)*** Email external partners:
  - [ ] Cloudflare: ask-research@cloudflare.com
    - **NOTE** :  We need to provide them with updated user agent string so they can update their internal machinery to prevent Tor Browser users from getting so many CAPTCHAs
  - [ ]  Startpage: admin@startpage.com
    - **NOTE** : Startpage also needs the updated user-agent string for better experience on their onion service sites.

</details>

<details>
  <summary>Signing</summary>

### release signing
- **NOTE** : In practice, it's most efficient to have the blog post and website updates ready to merge, since signing doesn't take very long
- [ ] Assign this issue to the signer, one of:
  - boklm
  - richard
- [ ] On `$(STAGING_SERVER)`, ensure updated:
  - [ ] `tor-browser-build` is on the right commit: `git tag -v tbb-$(TOR_BROWSER_VERSION)-$(TOR_BROWSER_BUILD_N) && git checkout tbb-$(TOR_BROWSER_VERSION)-$(TOR_BROWSER_BUILD_N)`
  - [ ] `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_builder` : ssh hostname of machine with unsigned builds
      - **NOTE** : `tor-browser-build` is expected to be in the `$HOME` directory)
    - `ssh_host_linux_signer` : ssh hostname of linux signing machine
  - [ ] `tor-browser-build/tools/signing/set-config.rcodesign-appstoreconnect`
    - `appstoreconnect_api_key_path` : path to json file containing appstoreconnect api key infos
  - [ ] `set-config.update-responses`
    - `update_responses_repository_dir` : directory where you cloned `git@gitlab.torproject.org:tpo/applications/tor-browser-update-responses.git`
  - [ ] `tor-browser-build/tools/signing/set-config.tbb-version`
    - `tbb_version` : tor browser version string, same as `var/torbrowser_version` in `rbm.conf` (examples: `11.5a12`, `11.0.13`)
    - `tbb_version_build` : the tor-browser-build build number (if `var/torbrowser_build` in `rbm.conf` is `buildN` then this value is `N`)
    - `tbb_version_type` : either `alpha` for alpha releases or `release` for stable releases
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, ensure tor daemon is running with SOCKS5 proxy on the default port 9050
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, run do-all-signing script:
  - `cd tor-browser-build/tools/signing/`
  - `./do-all-signing.torbrowser`
- **NOTE**: at this point the signed binaries should have been copied to `staticiforme`
- [ ] Update `staticiforme.torproject.org`:
  - From `screen` session on `staticiforme.torproject.org`:
  - [ ] Static update components : `static-update-component cdn.torproject.org && static-update-component dist.torproject.org`
  - [ ] Enable update responses : `sudo -u tb-release ./deploy_update_responses-alpha.sh`
  - [ ] Remove old release data from following places:
    - **NOTE** : Skip this step if we need to hold on to older versions for some reason (for example, this is an Andoid or Desktop-only release, or if we need to hold back installers in favor of build-to-build updates if there are signing issues, etc)
    - [ ] `/srv/cdn-master.torproject.org/htdocs/aus1/torbrowser`
    - [ ] `/srv/dist-master.torproject.org/htdocs/torbrowser`
  - [ ] Static update components (again) : `static-update-component cdn.torproject.org && static-update-component dist.torproject.org`

</details>

<details>
  <summary>Signature verification</summary>

  <details>
    <summary>Check whether the .exe files got properly signed and timestamped</summary>

```bash
# Point OSSLSIGNCODE to your osslsigncode binary
pushd tor-browser-build/${channel}/signed/$TORBROWSER_VERSION
OSSLSIGNCODE=/path/to/osslsigncode
../../../tools/authenticode_check.sh
popd
```

  </details>
  <details>
    <summary>Check whether the MAR files got properly signed</summary>

```bash
# Point NSSDB to your nssdb containing the mar signing certificate
# Point SIGNMAR to your signmar binary
# Point LD_LIBRARY_PATH to your mar-tools directory
pushd tor-browser-build/${channel}/signed/$TORBROWSER_VERSION
NSSDB=/path/to/nssdb
SIGNMAR=/path/to/mar-tools/signmar
LD_LIBRARY_PATH=/path/to/mar-tools/
../../../tools/marsigning_check.sh
popd
```

  </details>
</details>

<details>
  <summary>Publishing</summary>

### Google Play: https://play.google.com/apps/publish
- [ ] Publish APKs to Google Play:
  - Select `Tor Browser (Alpha)` app
  - Navigate to `Release > Production` and click `Create new release` button:
    - Upload the `tor-browser-android-*.apk` APKs
    - Update Release Name to Tor Browser version number
    - Update Release Notes
    - Next to 'Release notes', click `Copy from a previous release`
    - Edit blog post url to point to most recent blog post
  - Save, review, and configure rollout percentage
    - [ ] 25% rollout when publishing a scheduled update
    - [ ] 100% rollout when publishing a security-driven release
  - [ ] Update rollout percentage to 100% after confirmed no major issues

### website: https://gitlab.torproject.org/tpo/web/tpo.git
- [ ] `databags/versions.ini` : Update the downloads versions
    - `torbrowser-stable/version` : sort of a catch-all for latest stable version
    - `torbrowser-alpha/version` : sort of a catch-all for latest stable version
    - `torbrowser-*-stable/version` : platform-specific stable versions
    - `torbrowser-*-alpha/version` : platform-specific alpha versions
    - `tor-stable`,`tor-alpha` : set by tor devs, do not touch
- [ ] Push to origin as new branch, open 'Draft :' MR
- [ ] Remove `Draft:` from MR once signed-packages are accessible on https://dist.torproject.org
- [ ] Merge
- [ ] Publish after CI passes and builds are published

### blog: https://gitlab.torproject.org/tpo/web/blog.git
- [ ] Run `tools/signing/create-blog-post` which should create the new blog post from a template (edit set-config.blog to set you local blog directory)
  - [ ] Note any ESR update
  - [ ] Note any updates to dependencies (OpenSSL, zlib, NoScript, tor, etc)
  - [ ] Thank any users which have contributed patches  
  - [ ] **(Optional)** Draft any additional sections for new features which need testing, known issues, etc
- [ ] Push to origin as new branch, open `Draft:` MR
- [ ] Merge once signed-packages are accessible on https://dist.torproject.org
- [ ] Publish after CI passes and website has been updated

### tor-announce mailing list
- [ ] Email tor-announce mailing list: tor-announce@lists.torproject.org
  - **Subject**
    ```
    New Release: Tor Browser $(TOR_BROWSER_VERSION) (Android, Windows, macOS, Linux)
    ```
  - **Body**
    ```
    Hi everyone,

    Tor Browser $(TOR_BROWSER_VERSION) has now been published for all platforms. For details please see our blog post:
    - $(BLOG_POST_URL)

    Changelog:
    # paste changleog as quote here
    ```

</details>

/label ~"Release Prep"

