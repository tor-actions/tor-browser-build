<details>
  <summary>Explanation of variables</summary>

- `$(BUILD_SERVER)` : the server the main builder is using to build a tor-browser release
- `$(STAGING_SERVER)` : the server the signer is using to to run the signing process
- `$(ESR_VERSION)` : the Mozilla defined ESR version, used in various places for building tor-browser tags, labels, etc
    - example : `91.6.0`
- `$(RR_VERSION)` : the Mozilla defined Rapid-Release version; Tor Browser for Android is based off of the `$(ESR_VERSION)`, but Mozilla's Firefox for Android is based off of the `$(RR_VERSION)` so we need to keep track of security vulnerabilities to backport from the monthly Rapid-Release train and our frozen ESR train.
    - example: `103`
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
- `$(TOR_BROWSER_BRANCH)` : the full name of tor-browser branch
    - typically of the form: `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR-BROWSER_MINOR)-1`
- `$(TOR_BROWSER_BRANCH_PREV)` : the full name of the previous tor-browser branch (when rebasing)
</details>

<details>
    <summary>Desktop</summary>

### **torbutton** : https://gitlab.torproject.org/tpo/applications/torbutton.git
- [ ] Update translations :
  - [ ] `./import-translations.sh`
    - **NOTE** : if there are no new strings imported then we are done here
  - [ ] Commit with message `Translation updates`
    - **NOTE** : only add files which are already being tracked
- [ ] fixup! `tor-browser`'s `Bug 10760 : Integrate TorButton to TorBrowser core` issue to point to updated `torbutton` commit

</details>

<details>
    <summary>Android</summary>

### **Security Vulnerabilities Backport** : https://www.mozilla.org/en-US/security/advisories/
- [ ] Create tor-browser issue `Backport Android-specific Firefox $(RR_VERSION) to ESR $(ESR_VERSION)-based Tor Browser`
  - [ ] Link new backport issue to this release prep issue
- [ ] Go through any `Security Vulnerabilities fixed in Firefox $(RR_VERSION)` (or similar) and create list of CVEs which affect Android that need to be a backported
  - Potentially Affected Components:
    - `firefox`/`geckoview`
    - `application-services`
    - `android-components`
    - `fenix`

### **application-services** ***(Optional)*** : *TODO: we need to setup a gitlab copy of this repo that we can apply security backports to*
- [ ] Backport any Android-specific security fixes from Firefox rapid-release
- [ ] Sign/Tag commit:
  - Tag : `application-services-$(ESR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(BUILD_N)`
  - Message: `Tagging $(BUILD_N) for $(ESR_VERSION)-based stable`
- [ ] Push tag to `origin`

### **android-components** ***(Optional)*** : https://gitlab.torproject.org/tpo/applications/android-components.git
- [ ] Backport any Android-specific security fixes from Firefox rapid-release
- [ ] Sign/Tag commit:
  - Tag : `android-components-$(ESR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(BUILD_N)`
  - Message: `Tagging $(BUILD_N) for $(ESR_VERSION)-based stable)`
- [ ] Push tag to `origin`

### **fenix** ***(Optional)*** : https://gitlab.torproject.org/tpo/applications/fenix.git
- [ ] Backport any Android-specific security fixes from Firefox rapid-release
- [ ] Sign/Tag commit:
  - Tag : `tor-browser-$(ESR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(BUILD_N)`
  - Message: `Tagging $(BUILD_N) for $(ESR_VERSION)-based stable)`
- [ ] Push tag to `origin`

</details>

<details>
    <summary>Shared</summary>

### tor-browser: https://gitlab.torproject.org/tpo/applications/tor-browser.git
- [ ] ***(Optional)*** Backport any Android-specific security fixes from Firefox rapid-release
- [ ] ***(Optional, Chemspill)*** Backport security-fixes to both `tor-browser` and `base-browser` branches
- [ ] ***(Optional)*** Rebase to `$(ESR_VERSION)`
  - [ ] Find the Firefox hg tag here : https://hg.mozilla.org/releases/mozilla-esr102/tags
    - [ ] `$(ESR_TAG)` : `<INSERT_TAG_HERE>`
  - [ ] Identify the hg patch associated with above hg tag, and find the equivalent `gecko-dev` git commit (search by commit message)
    - [ ] `gecko-dev` commit : `<INSERT_COMMIT_HASH_HERE>`
    - [ ] Sign/Tag commit :
      - Tag : `$(ESR_TAG)`
      - Message : `Hg tag $(ESR_TAG)`
  - [ ] Create new branches with the discovered `gecko-dev` commit as `HEAD` named:
    - [ ] `base-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR-BROWSER_MINOR)-1`
    - [ ] `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR-BROWSER_MINOR)-1`
  - [ ] Push new branches and esr tag to origin
  - [ ] Rebase previous `base-browser` patches onto the `gecko-dev` commit
  - [ ] Rebase previous `tor-browser` patches onto the new `base-browser` branch
  - [ ] Compare patch-sets (ensure nothing *weird* happened during rebase):
    - [ ] rangediff: `git range-diff $(ESR_TAG_PREV)..$(TOR_BROWSER_BRANCH_PREV) $(ESR_TAG)..$(TOR_BROWSER_BRANCH)`
    - [ ] diff of diffs:
        -  Do the diff between `current_patchset.diff` and `rebased_patchset.diff` with your preferred `$(DIFF_TOOL)` and look at differences on lines that starts with + or -
        - [ ] `git diff $(ESR_TAG_PREV)..$(TOR_BROWSER_BRANCH_PREV) > current_patchset.diff`
        - [ ] `git diff $(ESR_TAG)..$(TOR_BROWSER_BRANCH) > rebased_patchset.diff`
        - [ ] `$(DIFF_TOOL) current_patchset.diff rebased_patchset.diff`
  - [ ] Open MR for the rebase
- [ ] Sign/Tag `base-browser` commit:
  - **NOTE** : Currently we are using the `Bug 40926: Implemented the New Identity feature` commit as the final commit of `base-browser` before `tor-browser`
  - Tag : `base-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-build1`
  - Message: `Tagging build1 for $(ESR_VERSION)esr-based stable`
- [ ] Sign/Tag `tor-browser` commit :
  - Tag : `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(FIREFOX_BUILD_N)`
  - Message : `Tagging $(FIREFOX_BUILD_N) for $(ESR_VERSION)esr-based stable`
- [ ] Push rebased branches and tags to `origin`

</details>

<details>
    <summary>Build</summary>

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Tor Browser Alpha (and Nightly) are on the `main` branch, while Stable lives in the various `maint-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)` (and possibly more specific) branches

- [ ] Update `rbm.conf`
  - [ ] `var/torbrowser_version` : update to next version
  - [ ] `var/torbrowser_build` : update to `$(TOR_BROWSER_BUILD_N)`
  - [ ] ***(Optional, Desktop)*** `var/torbrowser_incremental_from` : update to previous Desktop version
    - [ ] **IMPORTANT**: Really *actually* make sure this is the previous Desktop version or else the `make incrementals-*` step will fail
- [ ] ***(Optional)*** Update Desktop-specific build configs
  - [ ] Update `projects/firefox/config`
    - [ ] `git_hash` : update the `$(BUILD_N)` section to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] Update `projects/translation-base-browser/config`
    - [ ] `git_hash` : update with `HEAD` commit of project's `base-browser` branch
  - [ ] Update `projects/translation-base-browser-fluent/config`
    - [ ] `git_hash` : update with `HEAD` commit of project's `basebrowser-newidentityftl` branch
- [ ] ***(Optional)*** Update Android-specific build configs
  - [ ] ***(Optional)*** Update `projects/geckoview/config`
    - [ ] `git_hash` : update the `$(BUILD_N)` section to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/geckoview_version` : update to latest `$(ESR_VERSION)` if rebased
  - [ ] Update `projects/tba-translations/config`:
    - [ ]  `git_hash` : update with `HEAD` commit of project's `fenix-torbrowserstringsxml` branch
  - [ ] ***(Optional)*** Update `projects/tor-android-service/config`
    - [ ] `git_hash` : update with `HEAD` commit of project's `main` branch
  - [ ] ***(Optional)*** Update `projects/application-services/config`:
    **NOTE** we don't currently have any of our own patches for this project
    - [ ] `git_hash` : update to appropriate git commit associated with `$(ESR_VERSION)`
  - [ ] ***(Optional)*** Update `projects/android-components/config`:
    - [ ] `git_hash` : update the `$(BUILD_N)` section to match `android-components` tag
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
      - [ ] `version` : update to latest non `-alpha` tag (ping dgoulet or ahf if unsure)
  - [ ] Check for go updates here : https://golang.org/dl
    - **NOTE** : Tor Browser Stable uses the latest of the *previous* Stable major series go version (apart from the transition phase from Tor Browser Alpha to Stable, in which case Tor Browser Stable may use the latest major series go version)
    - [ ] ***(Optional)*** Update `projects/go/config`
      - [ ] `version` : update go version
      - [ ] `input_files/sha256sum` for `go` : update sha256sum of archive (sha256 sums are displayed on the go download page)
  - [ ] ***(Optional)*** Update the manual
    - [ ] Go to https://gitlab.torproject.org/tpo/web/manual/-/jobs/
    - [ ] Open the latest build stage
    - [ ] Download the artifacts (they come in a .zip file).
    - [ ] Rename it to `manual_$PIPELINEID.zip`
    - [ ] Upload it to people.tpo
    - [ ] Update `projects/manual/config`
      - [ ] Change the version to `$PIPELINEID`
      - [ ] Update the hash in the input_files section
      - [ ] Update the URL if you have uploaded to a different people.tpo home
- [ ] Update `ChangeLog.txt`
  - [ ] Ensure ChangeLog.txt is sync'd between alpha and stable branches
- [ ] Open MR with above changes
- [ ] Begin build on `$(BUILD_SERVER)` (and fix any issues which come up and update MR)
- [ ] Sign/Tag commit: `make signtag-release`
- [ ] Push tag to origin
</details>

<details>
	<summary>Communications</summary>

### notify stakeholders
- [ ] Email tor-qa mailing list: tor-qa@lists.torproject.org
  - [ ] Provide links to unsigned builds on `$(BUILD_SERVER)`
  - [ ] Note any new functionality which needs testing
  - [ ] Link to any known issues
- [ ] Email downstream consumers:
  - Recipients:
    - [ ] Tails dev mailing list: tails-dev@boum.org
    - [ ] Guardian Project: nathan@guardianproject.info
    - [ ] torbrowser-launcher: micah@micahflee.com
  - [ ] Provide links to unsigned builds on `$(BUILD_SERVER)`
  - [ ] Note any changes which may affect packaging/downstream integration
- [ ] Email upstream stakeholders:
  - [ ] ***(Optional, after ESR migration)*** Cloudflare: ask-research@cloudflare.com
    - **NOTE** :  We need to provide them with updated user agent string so they can update their internal machinery to prevent Tor Browser users from getting so many CAPTCHAs

</details>

<details>
  <summary>Signing/Publishing</summary>

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
    - `./do-all-signing.sh`
- **NOTE**: at this point the signed binaries should have been copied to `staticiforme`
- [ ] Update `staticiforme.torproject.org`:
  - From `screen` session on `staticiforme.torproject.org`:
  - [ ] Remove old release data from following places:
    - **NOTE** : Skip this step if the current release is Android or Desktop *only*
    - [ ] `/srv/cdn-master.torproject.org/htdocs/aus1/torbrowser`
    - [ ] `/srv/dist-master.torproject.org/htdocs/torbrowser`
  - [ ] Static update components : `static-update-component cdn.torproject.org && static-update-component dist.torproject.org`
  - [ ] Enable update responses : `./deploy_update_responses-alpha.sh`
- [ ] Publish APKs to Google Play:
  - Log into https://play.google.com/apps/publish
  - Select `Tor Browser` app
  - Navigate to `Release > Production` and click `Create new release` button
  - [ ] Upload the `*.multi.apk` APKs
  - [ ] Update Release Name to Tor Browser version number
  - [ ] Update Release Notes
    - Next to 'Release notes', click `Copy from a previous release`
    - [ ] Edit blog post url to point to most recent blog post
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

