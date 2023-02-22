<details>
  <summary>Explanation of variables</summary>

- `$(BUILD_SERVER)` : the server the main builder is using to build a tor-browser release
- `$(STAGING_SERVER)` : the server the signer is using to to run the signing process
- `$(ESR_VERSION)` : the Mozilla defined ESR version, used in various places for building tor-browser tags, labels, etc
    - example : `91.6.0`
- `$(ESR_TAG)` : the Mozilla defined hg (Mercurial) tag associated with `$(ESR_VERSION)`
    - exmaple : `FIREFOX_91_7_0esr_BUILD2`
- `$(ESR_TAG_PREV)` : the Mozilla defined hg (Mercurial) tag associated with the previous ESR version when rebasing (ie, the ESR version we are rebasing from)
- `$(TOR_BROWSER_MAJOR)` : the Tor Browser major version
    - example : `11`
- `$(TOR_BROWSER_MINOR)` : the Tor Browser minor version
    - example : either `0` or `5`; Alpha's is always `(Stable + 5) % 10`
- `$(BUILD_N)` : a project's build revision within a its branch; this is separate from the `$(TOR_BROWSER_BUILD_N)` value; many of the Firefox-related projects have a `$(BUILD_N)` suffix and may differ between projects even when they contribute to the same build.
    - example : `build1`
- `$(TOR_BROWSER_BUILD_N)` : the tor-browser build revision for a given Tor Browser release; used in tagging git commits
    - example : `build2`
    - **NOTE** : A project's `$(BUILD_N)` and `$(TOR_BROWSER_BUILD_N)` may be the same, but it is possible for them to diverge. For example :
        - if we have multiple Tor Browser releases on a given ESR branch the two will become out of sync as the `$(BUILD_N)` value will increase, while the `$(TOR_BROWSER_BUILD_N)` value may stay at `build1` (but the `$(TOR_BROWSER_VERSION)` will increase)
        - if we have build failures unrelated to `tor-browser`, the `$(TOR_BROWSER_BUILD_N)` value will increase while the `$(BUILD_N)` will stay the same.
- `$(TOR_BROWSER_VERSION)` : the published Tor Browser version
    - example : `11.5a6`, `11.0.7`
</details>

**NOTE** It is assumed that the `tor-browser` rebase and security backport tasks have been completed

<details>
  <summary>Build Updates</summary>

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Tor Browser Alpha (and Nightly) are on the `main` branch

- [ ] Update `rbm.conf`
  - [ ] `var/torbrowser_version` : update to next version
  - [ ] `var/torbrowser_build` : update to `$(TOR_BROWSER_BUILD_N)`
  - [ ] ***(Desktop Only)***`var/torbrowser_incremental_from` : update to previous Desktop version
    - **IMPORTANT**: Really *actually* make sure this is the previous Desktop version or else the `make incrementals-*` step will fail
- [ ] Update Desktop-specific build configs
  - [ ] Update `projects/firefox/config`
    - [ ] `git_hash` : update the `$(BUILD_N)` section to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] Update `projects/translation/config`:
    - [ ] run `make list_translation_updates-alpha` to get updated hashes
    - [ ] `steps/base-browser/git_hash` : update with `HEAD` commit of project's `base-browser` branch
    - [ ] `steps/base-browser-fluent/git_hash` : update with `HEAD` commit of project's `basebrowser-newidentityftl` branch
    - [ ] `steps/tor-browser/git_hash` : update with `HEAD` commit of project's `tor-browser` branch
    - [ ] `steps/fenix/git_hash` : update with `HEAD` commit of project's `fenix-torbrowserstringsxml` branch
- [ ] Update Android-specific build configs
  - [ ] ***(Optional)*** Update `projects/geckoview/config`
    - [ ] `git_hash` : update the `$(BUILD_N)` section to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/geckoview_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] ***(Optional)*** Update `projects/tor-android-service/config`
    - [ ] `git_hash` : update with `HEAD` commit of project's `main` branch
  - [ ] ***(Optional)*** Update `projects/application-services/config`:
    **NOTE** we don't currently have any of our own patches for this project
    - [ ] `git_hash` : update to appropriate git commit associated with `$(ESR_VERSION)`
  - [ ] ***(Optional)*** Update `projects/android-components/config`:
    - [ ] `git_hash` : update the `$(BUILD_N)` section to match alpha `android-components` tag
  - [ ] ***(Optional)*** Update `projects/fenix/config`
    - [ ] `git_hash` : update the `$(BUILD_N)` section to match `fenix` tag
    - [ ] ***(Optional)*** `var/fenix_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] Update allowed_addons.json by running (from `tor-browser-build` root):
    - `./tools/fetch_allowed_addons.py > projects/browser/allowed_addons.json`
- [ ] Update common build configs
  - [ ] Check for NoScript updates here : https://addons.mozilla.org/en-US/firefox/addon/noscript
    - [ ] ***(Optional)*** If new version available, update `noscript` section of `input_files` in `projects/browser/config`
      - [ ] `URL`
      - [ ] `sha256sum`
  - [ ] Check for OpenSSL updates here : https://www.openssl.org/source/
    - [ ] ***(Optional)*** If new 1.X.Y version available, update `projects/openssl/config`
      - [ ] `version` : update to next 1.X.Y version
      - [ ] `input_files/sha256sum` : update to sha256 sum of source tarball
  - [ ] Check for zlib updates here: https://github.com/madler/zlib/releases
    - [ ] **(Optional)** If new tag available, update `projects/zlib/config`
      - [ ] `version` : update to next release tag
  - [ ] Check for tor updates here : https://gitlab.torproject.org/tpo/core/tor/-/tags
    - [ ] ***(Optional)*** Update `projects/tor/config`
      - [ ] `version` : update to latest `-alpha` tag or release tag if newer (ping dgoulet or ahf if unsure)
  - [ ] Check for go updates here : https://golang.org/dl
    - **NOTE** : Tor Browser Alpha uses the latest Stable major series go version
    - [ ] ***(Optional)*** Update `projects/go/config`
      - [ ] `version` : update go version
      - [ ] `input_files/sha256sum` for `go` : update sha256sum of archive (sha256 sums are displayed on the go download page)
  - [ ] Update the manual : https://gitlab.torproject.org/tpo/web/manual/-/jobs/
    - [ ] Download the `artifacts.zip` file from latest build stage row (download icon button on the right)
    - [ ] Rename it to `manual_$PIPELINEID.zip`
    - [ ] Upload it to people.tpo
    - [ ] Update `projects/manual/config`
      - [ ] Change the version to `$PIPELINEID`
      - [ ] Update the hash in the input_files section
      - [ ] Update the URL if you have uploaded to a different people.tpo home
- [ ] Update `ChangeLog.txt`
  - [ ] Ensure ChangeLog.txt is sync'd between alpha and stable branches
  - [ ] Check the linked issues: ask people to check if any are missing, remove the not fixed ones
  - [ ] Run `tools/fetch-changelogs.py $(TOR_BROWSER_VERSION)` or `tools/fetch-changelogs.py '#$(ISSUE_NUMBER)'`
    - Make sure you have `requests` installed (e.g., `apt install python3-requests`)
    - The first time you run this script you will need to generate an access token; the script will guide you
  - [ ] Copy the output of the script to the beginning of `ChangeLog.txt` and adjust its output
    - If you used the issue number, you will need to write the Tor Browser version manually
  - [ ] Include any version updates for:
    - [ ] translations
    - [ ] OpenSSL
    - [ ] NoScript
    - [ ] Go
    - [ ] zlib
  - [ ] Include any ESR rebase for Firefox and GeckoView
- [ ] Open MR with above changes
- [ ] Begin build on `$(BUILD_SERVER)` (fix any issues which come up and update MR)
- [ ] Merge
- [ ] Sign/Tag commit: `make signtag-alpha`
- [ ] Push tag to `origin`

</details>

<details>
  <summary>Communications</summary>

### notify stakeholders

  <details>
    <summary>email template</summary>

      Hello All,

      Unsigned Tor Browser $(TOR_BROWSER_VERSION) alpha candidate builds are now available for testing:

      - https://tb-build-05.torproject.org/~$(BUILDER)/builds/release/unsigned/$(TOR_BROWSER_VERSION)/

      The full changelog can be found here:

      - https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/raw/main/projects/browser/Bundle-Data/Docs/ChangeLog.txt

  </details>

- [ ] Email tor-qa mailing list: tor-qa@lists.torproject.org
  - Additional information:
    - [ ] Note any new functionality which needs testing
    - [ ] Link to any known issues
- [ ] ***(Optional, only around build/packaging changes)*** Email downstream consumers:
  - Recipients:
    - Tails dev mailing list: tails-dev@boum.org
    - Guardian Project: nathan@guardianproject.info
    - torbrowser-launcher: micah@micahflee.com
    - FreeBSD port: freebsd@sysctl.cz <!-- Gitlab user maxfx -->
    - OpenBSD port: caspar@schutijser.com <!-- Gitlab user cschutijser -->
  - [ ] Note any changes which may affect packaging/downstream integration
- [ ] Email upstream stakeholders:
  - ***(Optional, after ESR migration)*** Cloudflare: ask-research@cloudflare.com
    - **NOTE** :  We need to provide them with updated user agent string so they can update their internal machinery to prevent Tor Browser users from getting so many CAPTCHAs

</details>

<details>
  <summary>Signing</summary>

### signing + publishing
- [ ] Ensure builders have matching builds
- [ ] On `$(STAGING_SERVER)`, ensure updated:
  - [ ] `tor-browser-build/tools/signing/set-config`
    - `NSS_DB_DIR` : location of the `nssdb7` directory
  - [ ]  `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_builder` : ssh hostname of machine with unsigned builds
      - **NOTE** : `tor-browser-build` is expected to be in the `$HOME` directory)
    - `ssh_host_linux_signer` : ssh hostname of linux signing machine
    - `ssh_host_macos_signer` : ssh hostname of macOS signing machine
  - [ ] `tor-browser-build/tools/signing/set-config.macos-notarization`
    - `macos_notarization_user` : the email login for a tor notariser Apple Developer account
  - [ ] `set-config.update-responses`
    - `update_responses_repository_dir` : directory where you cloned `git@gitlab.torproject.org:tpo/applications/tor-browser-update-responses.git`
  - [ ] `tor-browser-build/tools/signing/set-config.tbb-version`
    - `tbb_version` : tor browser version string, same as `var/torbrowser_version` in `rbm.conf` (examples: `11.5a12`, `11.0.13`)
    - `tbb_version_build` : the tor-browser-build build number (if `var/torbrowser_build` in `rbm.conf` is `buildN` then this value is `N`)
    - `tbb_version_type` : either `alpha` for alpha releases or `release` for stable releases
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, run the macOS proxy script:
    - `cd tor-browser-build/tools/signing/`
    - `./macos-signer-proxy`
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, ensure tor daemon is running with SOCKS5 proxy on the default port 9050
- [ ] apk signing : copy signed `*multi.apk` files to the unsigned build outputs directory
- [ ] run do-all-signing script:
    - `cd tor-browser-build/tools/signing/`
    - `./do-all-signing.torbrowser`
- **NOTE**: at this point the signed binaries should have been copied to `staticiforme`
- [ ] Update `staticiforme.torproject.org`:
  - From `screen` session on `staticiforme.torproject.org`:
  - [ ] Static update components : `static-update-component cdn.torproject.org && static-update-component dist.torproject.org`
  - [ ] Enable update responses : `sudo -u tb-release ./deploy_update_responses-alpha.sh`
  - [ ] Remove old release data from following places:
    - **NOTE** : Skip this step if the current release is Android or Desktop *only*
    - [ ] `/srv/cdn-master.torproject.org/htdocs/aus1/torbrowser`
    - [ ] `/srv/dist-master.torproject.org/htdocs/torbrowser`
  - [ ] Static update components (again) : `static-update-component cdn.torproject.org && static-update-component
- [ ] Publish APKs to Google Play:
  - Log into https://play.google.com/apps/publish
  - Select `Tor Browser (Alpha)` app
  - Navigate to `Release > Production` and click `Create new release` button:
    - Upload the `*.multi.apk` APKs
    - Update Release Name to Tor Browser version number
    - Update Release Notes
    - Next to 'Release notes', click `Copy from a previous release`
    - Edit blog post url to point to most recent blog post
  - Save, review, and configure rollout percentage
    - [ ] 25% rollout when publishing a scheduled update
    - [ ] 100% rollout when publishing a security-driven release
  - [ ] Update rollout percentage to 100% after confirmed no major issues

</details>

<details>
  <summary>Publishing</summary>

### website: https://gitlab.torproject.org/tpo/web/tpo.git
- [ ] `databags/versions.ini` : Update the downloads versions
    - `torbrowser-stable/version` : sort of a catch-all for latest stable version
    - `torbrowser-alpha/version` : sort of a catch-all for latest stable version
    - `torbrowser-*-stable/version` : platform-specific stable versions
    - `torbrowser-*-alpha/version` : platform-specific alpha versions
    - `tor-stable`,`tor-alpha` : set by tor devs, do not touch
- [ ] Push to origin as new branch, open 'Draft :' MR
- [ ] Remove `Draft:` from MR once signed-packages are uploaded
- [ ] Merge
- [ ] Publish after CI passes and builds are published

### blog: https://gitlab.torproject.org/tpo/web/blog.git

- [ ] Duplicate previous Stable or Alpha release blog post as appropriate to new directory under `content/blog/new-release-tor-browser-$(TOR_BROWSER_VERSION)` and update with info on release :
    - [ ] Update Tor Browser version numbers
    - [ ] Note any ESR rebase
    - [ ] Link to any Firefox security updates from ESR upgrade
    - [ ] Link to any Android-specific security backports
    - [ ] Note any updates to :
      - tor
      - OpenSSL
      - NoScript
    - [ ] Convert ChangeLog.txt to markdown format used here by :
      - `tor-browser-build/tools/changelog-format-blog-post`
- [ ] Push to origin as new branch, open `Draft:` MR
- [ ] Remove `Draft:` from MR once signed-packages are uploaded
- [ ] Merge
- [ ] Publish after CI passes and website has been updated

### tor-announce mailing list
- [ ] Send an email to tor-announce@lists.torproject.org, using the same content as the blog post and subject "Tor Browser $version is released".

</details>

/label ~"Release Prep"

