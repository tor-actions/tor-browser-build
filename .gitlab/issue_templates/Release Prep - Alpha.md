<details>
  <summary>Explanation of variables</summary>

- `$(BUILD_SERVER)` : the server the main builder is using to build a tor-browser release
- `$(STAGING_SERVER)` : the server the signer is using to to run the signing process
- `$(TOR_LAUNCHER_VERSION)` : version of `tor-launcher`, used in tags
    - example : `0.2.33`
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

### **torbutton** : https://git.torproject.org/torbutton.git
- [ ] Update translations :
  - [ ] `./import-translations.sh`
    - **NOTE** : if there are no new strings imported then we are done here
  - [ ] Commit with message `Translation updates`
    - **NOTE** : only add files which are already being tracked
  - [ ] ***(Optional)*** Backport to maintenance branch if present and necessary
- [ ] fixup! `tor-browser`'s `Bug 10760 : Integrate TorButton to TorBrowser core` issue to point to updated `torbutton` commit

### **tor-launcher** : https://git.torproject.org/tor-launcher.git
- [ ] Update translations:
  - [ ] ./localization/import-translations.sh
  - **NOTE** : if there are no new strings imported then we are done here
- [ ] Update `install.rdf` file with new version
- [ ] Sign/Tag commit :
  - Tag : `$(TOR_LAUNCHER_VERSION)`
  - Message `Tagging $(TOR_LAUNCHER_VERSION)`
- [ ] Push `main` and tag to origin

</details>

<details>
    <summary>Android</summary>

### **tba-translation** : https://git.torproject.org/translation.git
- [ ] Fetch latest and identify new `HEAD` of `fenix-torbrowserstringsxml` branch
  - [ ] `origin/fenix-torbrowserstringsxml` : `<INSERT COMMIT HASH HERE>`

### **tor-android-service** ***(Optional)***: https://git.torproject.org/tor-android-service.git
- [ ] Fetch latest and identify new `HEAD` of `main` branch
  - [ ] `origin/main` : `<INSERT COMMIT HASH HERE>`

### ***Security Vulnerabilities Backport*** : https://www.mozilla.org/en-US/security/advisories/
- [ ] Go through any `Security Vulnerabilities fixed in Firefox $(RR_VERSION)` (or similar) and create list of CVEs which affect Android that need to be a backported
  - Potentially Affected Components:
    - `firefox`
    - `application-services`
    - `android-components`
    - `fenix`
- [ ] Create issue for each backport in `tor-browser` and merge requests for `cherry-pick`'d fixes in each affected component
- [ ] Link each created backport issue to this release prep issue

### **application-services** : *TODO: we need to setup a gitlab copy of this repo that we can apply security backports to*
- [ ] ***(Optional)*** Backport any Android-specific security fixes from Firefox rapid-release
- [ ] Sign/Tag commit:
  - Tag : `application-services-$(ESR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(BUILD_N)`
  - Message: `Tagging $(BUILD_N) for $(ESR_VERSION)-based (alpha|stable)`
- [ ] Push tag to `origin`

### **android-components** : https://gitlab.torproject.org/tpo/applications/android-components.git
- [ ] ***(Optional)*** Backport any Android-specific security fixes from Firefox rapid-release
- [ ] Sign/Tag commit:
  - Tag : `android-components-$(ESR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(BUILD_N)`
  - Message: `Tagging $(BUILD_N) for $(ESR_VERSION)-based (alpha|stable)`
- [ ] Push tag to `origin`

### **fenix** : https://gitlab.torproject.org/tpo/applications/fenix.git
- [ ] ***(Optional)*** Backport any Android-specific security fixes from Firefox rapid-release
- [ ] Sign/Tag commit:
  - Tag : `tor-browser-$(ESR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(BUILD_N)`
  - Message: `Tagging $(BUILD_N) for $(ESR_VERSION)-based (alpha|stable)`
- [ ] Push tag to `origin`

</details>

<details>
    <summary>Shared</summary>

### tor-browser: https://git.torproject.org/tor-browser.git
- [ ] ***(Optional)*** Backport any Android-specific security fixes from Firefox rapid-release
- [ ] ***(Optional)*** Rebase to `$(ESR_VERSION)`
  - [ ] Find the Firefox hg tag here : https://hg.mozilla.org/releases/mozilla-esr102/tags
    - [ ] `$(ESR_TAG)` : `<INSERT_TAG_HERE>`
  - [ ] Identify the hg patch associated with above hg tag, and find the equivalent `gecko-dev` git commit (search by commit message)
    - [ ] `gecko-dev` commit : `<INSERT_COMMIT_HASH_HERE>`
  - [ ] Create new `tor-browser` branch with the discovered `gecko-dev` commit as `HEAD` named `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR-BROWSER_MINOR)-1`
    - [ ] Sign/Tag commit :
      - Tag : `$(ESR_TAG)`
      - Message : `Hg tag $(ESR_TAG)`
  - [ ] Push new branch and tag to origin
  - [ ] Rebase `tor-browser` patches
  - [ ] Compare patch-sets (ensure nothing *weird* happened during rebase):
    - [ ] rangediff: `git range-diff $(ESR_TAG_PREV)..$(TOR_BROWSER_BRANCH_PREV) $(ESR_TAG)..$(TOR_BROWSER_BRANCH)`
    - [ ] diff of diffs:
        -  Do the diff between `current_patchset.diff` and `rebased_patchset.diff` with your preferred `$(DIFF_TOOL)` and look at differences on lines that starts with + or -
        - [ ] `git diff $(ESR_TAG_PREV)..$(TOR_BROWSER_BRANCH_PREV) > current_patchset.diff`
        - [ ] `git diff $(ESR_TAG)..$(TOR_BROWSER_BRANCH) > rebased_patchset.diff`
        - [ ] `$(DIFF_TOOL) current_patchset.dif rebased_patchset.deff`
  - [ ] Open MR for the rebase
- [ ] Sign/Tag `base-browser` commit:
  - **NOTE** : Currently we are using the `Bug 27511: Add new identity button to toolbar` commit as the dividing line between `base-browser` and `tor-browser`
  - **NOTE** : If we need to prepare a release without a rebase that includes a patch that needs to be in the `base-browser` section (such as a Mozilla chemspill release) we will create an entirely new branch with a `-2` suffix
  - Tag : `base-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-build1`
  - Message: `Tagging build1 for $(ESR_VERSION)esr-based (alpha|stable)`
- [ ] Sign/Tag `tor-browser` commit :
  - Tag : `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(FIREFOX_BUILD_N)`
  - Message : `Tagging $(FIREFOX_BUILD_N) for $(ESR_VERSION)esr-based (alpha|stable)`
- [ ] Push tag to `origin`
- [ ] Update Gitlab Default Branch to new Alpha branch:  https://gitlab.torproject.org/tpo/applications/tor-browser/-/settings/repository

</details>

<details>
    <summary>Build/Signing/Publishing</summary>

### tor-browser-build: https://git.torproject.org/builders/tor-browser-build.git
Tor Browser Alpha (and Nightly) are on the `main` branch, while Stable lives in the various `$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-maint` (and possibly more specific) branches

- [ ] Update `rbm.conf`
  - [ ] `var/torbrowser_version` : update to next version
  - [ ] `var/torbrowser_build` : update to `$(TOR_BROWSER_BUILD_N)`
  - [ ] ***(Desktop Only)*** `var/torbrowser_incremental_from` : update to previous Desktop version
    - [ ] **IMPORTANT**: Really *actually* make sure this is the previous Desktop version or else the `make incrementals-*` step will fail
- [ ] Update `projects/firefox/config`
  - [ ] `git_hash` : update the `$(BUILD_N)` section to match `tor-browser` tag
  - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest `$(ESR_VERSION)` if rebased
- [ ] Update `projects/geckoview/config`
  - [ ] `git_hash` : update the `$(BUILD_N)` section to match `tor-browser` tag
  - [ ] ***(Optional)*** `var/geckoview_version` : update to latest `$(ESR_VERSION)` if rebased
- [ ] Update `projects/translation-base-browser/config`
  - [ ] `git_hash` : update with `HEAD` commit of project's `base-browser` branch
- [ ] Update `projects/tba-translations/config`:
  - [ ]  `git_hash` : update with `HEAD` commit of project's `fenix-torbrowserstringsxml` branch
- [ ] Update `projects/tor-android-service/config`
  - [ ] `git_hash` : update with `HEAD` commit of project's `main` branch
- [ ] Update `projects/application-services/config`:
  **NOTE** we don't have any of our own patches for this project
  - [ ] `git_hash` : update to appropriate git commit associated with $(ESR_VERSION)
- [ ] Update `projects/android-components/config`:
  - [ ] `git_hash` : update the `$(BUILD_N)` section to match alpha `android-components` tag
- [ ] Update `projects/fenix/config`
  - [ ] `git_hash` : update the `$(BUILD_N)` section to match `fenix` tag
  - [ ] ***(Optional)*** `var/fenix_version` : update to latest `$(ESR_VERSION)` if rebased
- [ ] Update allowed_addons.json by running (from `tor-browser-build` root):
  - `./tools/fetch_allowed_addons.py > projects/browser/allowed_addons.json`
- [ ] Check for NoScript updates here : https://addons.mozilla.org/en-US/firefox/addon/noscript
  - [ ] ***(Optional)*** If new version available, update `noscript` section of `input_files` in `projects/browser/config`
    - [ ] `URL`
    - [ ] `sha256sum`
- [ ] Check for OpenSSL updates here : https://github.com/openssl/openssl/tags
  - [ ] ***(Optional)*** If new 1.X.Y series tag available, update `projects/openssl/config`
    - [ ] `version` : update to next 1.X.Y release tag
    - [ ] `input_files/sha256sum` : update to sha256 sum of source tarball
- [ ] Check for tor updates here : https://gitlab.torproject.org/tpo/core/tor/-/tags ; Tor Browser Alpha uses `-alpha` tagged tor, while stable uses the stable series
  - [ ] ***(Optional)*** Update `projects/tor/config`
    - [ ] `version` : update to next release tag
- [ ] Check for go updates here : https://golang.org/dl
  - **NOTE** : Tor Browser Alpha uses the latest Stable go version, while Tor Browser Stable uses the latest of the previous Stable major series version
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
- [ ] Begin build on `$(BUILD_SERVER)` (and fix any issues which come up)
- [ ] Sign/Tag commit : `make signtag-(alpha|release)`
- [ ] Push tag to origin

### notify stakeholders
- [ ] Email tor-qa mailing list: tor-qa@lists.torproject.org
    - [ ] Provide links to unsigned builds on `$(BUILD_SERVER)`
    - [ ] Call out any new functionality which needs testing
    - [ ] Link to any known issues
- [ ] Email Tails dev mailing list: tails-dev@boum.org
    - [ ] Provide links to unsigned builds on `$(BUILD_SERVER)`

### blog: https://gitlab.torproject.org/tpo/web/blog.git

- [ ] Duplicate previous Stable or Alpha release blog post as appropriate to new directory under `content/blog/new-release-tor-browser-$(TOR_BROWSER_VERSION)` and update with info on release :
    - [ ] Update Tor Browser version numbers
    - [ ] Note any ESR rebase
    - [ ] Note any Rapid Release rebase
    - [ ] Link to any Firefox security updates
    - [ ] Note any updates to :
        - [ ] tor
        - [ ] OpenSSL
        - [ ] go
        - [ ] NoScript
    - [ ] Convert ChangeLog.txt to markdown format used here by : `tor-browser-build/tools/changelog-format-blog-post`
- [ ] Push to origin as new branch, open 'Draft :' MR
- [ ] Remove `Draft:` from MR once signed-packages are uploaded
- [ ] Merge
- [ ] Publish after CI passes

### website: https://gitlab.torproject.org/tpo/web/tpo.git
- [ ] `databags/versions.ini` : Update the downloads versions
    - `torbrowser-stable/version` : sort of a catch-all for latest stable version
    - `torbrowser-stable/win32` : tor version in the expert bundle
    - `torbrowser-*-stable/version` : platform-specific stable versions
    - `torbrowser-*-alpha/version` : platform-specific alpha versions
    - `tor-stable`,`tor-alpha` : set by tor devs, do not touch
- [ ] Push to origin as new branch, open 'Draft :' MR
- [ ] Remove `Draft:` from MR once signed-packages are uploaded
- [ ] Merge
- [ ] Publish after CI passes

### signing + publishing
- [ ] Ensure builders have matching builds
- [ ] On `$(STAGING_SERVER)`, ensure updated:
  - [ ] `tor-browser-build/tools/signing/set-config`
    - [ ] `NSS_DB_DIR` : location of the `nssdb7` directory
  - [ ]  `tor-browser-build/tools/signing/set-config.hosts`
    - [ ] `ssh_host_builder` : ssh hostname of machine with unsigned builds
      - **NOTE** : `tor-browser-build` is expected to be in the `$HOME` directory)
    - [ ] `ssh_host_linux_signer` : ssh hostname of linux signing machine
    - [ ] `ssh_host_macos_signer` : ssh hostname of macOS signing machine
  - [ ] `tor-browser-build/tools/signing/set-config.macos-notarization`
    - [ ] `macos_notarization_user` : the email login for a tor notariser Apple Developer account
  - [ ] `tor-browser-build/tools/signing/set-config.tbb-version`
    - [ ] `tbb_version` : tor browser version string, same as `var/torbrowser_version` in `rbm.conf` (examples: `11.5a12`, `11.0.13`)
    - [ ] `tbb_version_build` : the tor-browser-build build number (if `var/torbrowser_build` in `rbm.conf` is `buildN` then this value is `N`)
    - [ ] `tbb_version_type` : either `alpha` for alpha releases or `release` for stable releases
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, run the macOS proxy script:
    - `cd tor-browser-build/tools/signing/`
    - `./macos-signer-proxy`
- [ ] On `$(STAGING_SERVER)` in a separate `screen` session, ensure tor daemon is running with SOCKS5 proxy on the default port 9050
- [ ] apk signing : *TODO*
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
  - [ ] Enable update responses :
    - [ ] alpha: `./deploy_update_responses-alpha.sh`
    - [ ] release: `./deploy_update_responses-release.sh`
- [ ] Publish APKs to Google Play:
  - [ ] Log into https://play.google.com/apps/publish
  - [ ] Select `Tor Browser (Alpha)` app
  - [ ] Navigate to `Release > Production` and click `Create new release` button
  - [ ] Upload the `*.multi.apk` APKs
  - [ ] If necessary, update the 'Release Name' (should be automatically populated)
  - [ ] Update Release Notes
    - [ ] Next to 'Release notes', click `Copy from a previous release`
    - [ ] Edit blog post url to point to most recent blog post
  - [ ] Save, review, and configure rollout percentage
    - [ ] 25% rollout when publishing a scheduled update
    - [ ] 100% rollout when publishing a security-driven release
  - [ ] Update rollout percentage to 100% after confirmed no major issues

### tor-announce mailing list
- [ ] Send an email to tor-announce@lists.torproject.org, using the same content as the blog post and subject "Tor Browser $version is released".

</details>

/label ~"Release Prep"

