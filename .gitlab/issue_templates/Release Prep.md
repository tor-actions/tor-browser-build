<details>
  <summary>Explanation of variables</summary>

- `$(BUILD_SERVER)` : the server the main builder is using to build a tor-browser release
- `$(STAGING_SERVER)` : the server the signer is using to to run the signing process
- `$(TOR_LAUNCHER_VERSION)` : version of `tor-launcher`, used in tags
    - example : `0.2.33`
- `$(ESR_VERSION)` : the Mozilla defined ESR version, used in various places for building tor-browser tags, labels, etc
    - example : `91.6.0`
- `$(ESR_TAG)` : the Mozilla defined hg (Mercurial) tag associated with `$(ESR_VERSION)`
    - exmaple : `FIREFOX_91_7_0esr_BUILD2`
- `$(ESR_TAG_PREV)` : the Mozilla defined hg (Mercurial) tag associated with the previous ESR version when rebasing (ie, the ESR version we are rebasing from)
- `$(RR_VERSION)` : the Mozilla defined 'Rapid Relese' version, used in various places for building geckoview tags, labels, etc
    - example : `96.0.3`
- `$(RR_TAG)` : the Mozilla defined hg (Mercurial) tag associated with `$(ESR_VERSION)`
    - exmaple : `FIREFOX_96_0_3_RELEASE`
- `$(RR_TAG_PREV)` : the Mozilla defined hg (Mercurial) tag associated with the previous ESR version when rebasing (ie, the ESR version we are rebasing from)
- `$(TOR_BROWSER_MAJOR)` : the Tor Browser major version
    - example : `11`
- `$(TOR_BROWSER_MINOR)` : the Tor Browser minor version
    - example : either `0` or `5`; Alpha's is always `(Stable + 5) % 10`
- `$(FIREFOX_BUILD_N)` : the firefox build revision within a given `tor-browser` branch; this is separate from the `$(TOR_BROWSER_BUILD_N) ` value
    - example : `build1`
- `$(GECKOVIEW_BUILD_N)` : like `$(FIREFOX_BUILD_N)` but for geckoview branches
- `$(FENIX_BUILD_N)` : like `$(FIREFOX_BUILD_N)` but for fenix branches
- `$(TOR_BROWSER_BUILD_N)` : the tor-browser build revision for a given Tor Browser release; used in tagging git commits
    - example : `build2`
    - **NOTE** : `$(FIREFOX_BUILD_N)` and `$(TOR_BROWSER_BUILD_N)` typically are the same, but it is possible for them to diverge. For example :
        - if we have multiple Tor Browser releases on a given ESR branch the two will become out of sync as the `$(FIREFOX_BUILD_N)` value will increase, while the `$(TOR_BROWSER_BUILD_N)` value may stay at `build1` (but the `$(TOR_BROWSER_VERSION)` will increase)
        - if we have build failures unrelated to `tor-browser`, the `$(TOR_BROWSER_BUILD_N)` value will increase while the `$(FIREFOX_BUILD_N)` will stay the same.
- `$(TOR_BROWSER_VERSION)` : the published Tor Browser version
    - example : `11.5a6`, `11.0.7`
- `$(TOR_BROWSER_BRANCH)` : the full name of tor-browser branch
    - typically of the form: `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR-BROWSER_MINOR)-1`
- `$(TOR_BROWSER_BRANCH_PREV)` : the full name of the previous tor-browser branch (when rebasing)
- `$(GECKOVIEW_BRANCH)` : the full name of geckoview branch
    - typically of the form: `tor-browser-$(RR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR-BROWSER_MINOR)-1`
- `$(GECKOVIEW_BRANCH_PREV)` : the full name of the previous geckoview branch (when rebasing)
</details>

<details>
    <summary>Desktop</summary>

### **torbutton** ***(Optional)***: https://git.torproject.org/torbutton.git
- [ ] ***(Optional)*** Update translations :
  - **NOTE** : mandatory if we have added new string dependencies
  -  [ ] `./import-translations.sh`
  -  [ ] Commit with message `Translation updates`
     - **NOTE** : only add files which are already being tracked
  -  [ ] *(Optional)* Backport to maintenance branch if present
- [ ] fixup! `tor-browser`'s `Bug 10760 : Integrate TorButton to TorBrowser core` issue to point to updated `torbutton` commit

### **tor-launcher** ***(Optional)***: https://git.torproject.org/tor-launcher.git
- [ ] ***(Optional)*** Update translations:
  - **NOTE** : mandatory if we have added new string dependencies
  - [ ] ./localization/import-translations.sh
  - [ ] Commit with message `Translation updates`
- [ ] Update `install.rdf` file with new version
- [ ] Sign/Tag commit :
    - Tag : `$(TOR_LAUNCHER_VERSION)`
    - Message `Tagging $(TOR_LAUNCHER_VERSION)`
- [ ] Push `main` and tag to origin

### tor-browser: https://git.torproject.org/tor-browser.git
- [ ] ***(Optional)*** Rebase to `$(ESR_VERSION)`
    - [ ] Find the Firefox hg tag here : https://hg.mozilla.org/releases/mozilla-esr91/tags
        - [ ] `$(ESR_TAG)` : `INSERT_TAG_HERE`
    - [ ] Identify the hg patch associated with above hg tag, and find the equivalent `gecko-dev` git commit (search by commit message)
        - [ ] `gecko-dev` commit : `INSERT_COMMIT_HASH_HERE`
    - [ ] Create new `tor-browser` branch with the discovered `gecko-dev` commit as `HEAD` named `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR-BROWSER_MINOR)-1`
    - [ ] Sign/Tag commit :
        - Tag : `$(ESR_TAG)`
        - Message : `Hg tag $(ESR_TAG)`
    - [ ] Push new branch and tag to origin
    - [ ] Rebase `tor-browser` patches
    - [ ] Perform rangediff to ensure nothing weird happened resolving conflicts
        - `git range-diff $(ESR_TAG_PREV)..$(TOR_BROWSER_BRANCH_PREV) $(ESR_TAG)..$(TOR_BROWSER_BRANCH)`
    - [ ] Open MR for the rebase
- [ ] ***(Alpha Only)*** Sign/Tag base-browser commit:
    **NOTE** : Currently we are using the `Bug 27511: Add new identity button to toolbar` commit as the dividing line between `base-browser` and `tor-browser`
    - Tag : `base-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-build1
    - Message: `Tagging build1 for $(ESR_VERSION)esr-based (alpha|stable)`
- [ ] ***(Optional)*** Backport any required patches to Stable
    - [ ] cherry-pick patches on top of rebased branch (issues to backport should have `Backport` label and be linked to the associated `Release Prep` issue
    - [ ] Close associated `Backport` issues
    - [ ] Open MR for the backport commits
- [ ] Sign/Tag commit :
    - Tag : `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(FIREFOX_BUILD_N)`
    - Message : `Tagging $(FIREFOX_BUILD_N) for $(ESR_VERSION)esr-based (alpha|stable)`
- [ ] Push tag to origin
- [ ] ***(Alpha Only)*** Update Gitlab Default Branch to new Alpha branch
     - https://gitlab.torproject.org/tpo/applications/tor-browser/-/settings/repository

</details>

<details>
    <summary>Android</summary>

### **geckoview**: https://git.torproject.org/tor-browser.git
- [ ] ***(Optional)*** Rebase to `$(RR_VERSION)`
    - [ ] Find the Firefox hg tag here : https://hg.mozilla.org/releases/mozilla-release/tags
        - [ ] `$(RR_TAG)` : `INSERT_TAG_HERE`
    - [ ] Identify the hg patch associated with above hg tag, and find the equivalent `gecko-dev` git commit (search by commit message)
        - [ ] `gecko-dev` commit : `INSERT_COMMIT_HASH_HERE`
    - [ ] Create new `geckoview` branch with the discovered `gecko-dev` commit as `HEAD` named `geckoview-$(RR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR-BROWSER_MINOR)-1`
    - [ ] Sign/Tag commit :
        - Tag : `$(RR_TAG)`
        - Message : `Hg tag $(RR_TAG)`
    - [ ] Push new branch and tag to origin
    - [ ] Rebase `geckoview` patches
    - [ ] Perform rangediff to ensure nothing weird happened resolving conflicts
        - `git range-diff $(RR_TAG_PREV)..$(GECKOVIEW_BRANCH_PREV) $(RR_TAG)..$(GECKOVIEW_BRANCH)`
    - [ ] Open MR for the rebase
    - [ ] Merge + Push
- [ ] ***(Optional)*** Backport any required patches to Stable
    - [ ] cherry-pick patches on top of rebased branch (issues to backport should have `Backport` label and be linked to the associated `Release Prep` issue
    - [ ] Close associated `Backport` issues
    - [ ] Open MR for the backport commits
    - [ ] Merge + Push
- [ ] Sign/Tag commit :
    - Tag : `geckoview-$(RR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(FIREFOX_BUILD_N)`
    - Message : `Tagging $(FIREFOX_BUILD_N) for $(RR_VERSION)-based (alpha|stable)`
- [ ] Push tag to origin

### **tba-translation** ***(Optional)***: https://git.torproject.org/translation.git
- [ ] Fetch latest and identify new HEAD of `fenix-torbrowserstringsxml` branch
  - [ ] `origin/fenix-torbrowserstringsxml` : `INSERT COMMIT HASH HERE`

### **android-components** ***(Optional)***: https://gitlab.torproject.org/tpo/applications/android-components.git
- [ ] ***(Optional)*** Rebase to `$(RR_VERSION)`
  - Upstream git repo : https://github.com/mozilla-mobile/android-components.git
  - [ ] Identify the `mozilla-mobile` git tag to start from
    - Seem to be in the form `v$(RR_VERSION)` (for example, `v99.0.3`)
  - [ ] Create new branch from tag named `android-components-$(RR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1`
  - [ ] Push new branch to origin
  - [ ] Rebase `android-components` patches
  - [ ] Perform rangediff to ensure nothing weird happened resolving conflicts
  - [ ] Open MR for the rebase
  - [ ] Merge + Push
 - [ ] ***(Optional)*** Backport any required patches to Stable
  - [ ] cherry-pick patches on top of rebased branch (issues to backport should have `Backport` label and be linked to the associated `Release Prep` issue
  - [ ] Close associated `Backport` issues
  - [ ] Open MR for the backport commits
  - [ ] Merge + Push
- [ ] Sign/Tag commit:
  - Tag : `android-components-$(RR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(BUILD_N)`
  - Message: `Tagging $(BUILD_N) for $(RR_VERSION)-based (alpha|stable)`
- [ ] Push tag to origin

### **tor-android-service** ***(Optional)***: https://git.torproject.org/tor-android-service.git
- [ ] Fetch latest and identify new HEAD of `master` branch
  - [ ] `origin/master` : `INSERT COMMIT HASH HERE`

### **fenix** ***(Optional)***: https://gitlab.torproject.org/tpo/applications/fenix.git
- [ ] ***(Optional)*** Rebase to `$(RR_VERSION)`
  - Upstream git repo : https://github.com/mozilla-mobile/fenix.git
  - [ ] Identify the `mozilla-mobile` git tag to start from
    - Seem to be in the form `v$(RR_VERSION)` (for example, `v96.3.0`)
  - [ ] Create new branch from tag named `tor-browser-$(RR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1`
    - **NOTE** : it is weird but we do use `tor-browser` here rather than `fenix`
  - [ ] Push new branch to origin
  - [ ] Rebase `fenix` patches
  - [ ] Perform rangediff to ensure nothing weird happened resolving conflicts
  - [ ] Open MR for the rebase
  - [ ] Merge + Push
 - ***(Optional)*** Backport any required patches to Stable
- [ ] ***(Optional)*** Backport any required patches to Stable
  - [ ] cherry-pick patches on top of rebased branch (issues to backport should have `Backport` label and be linked to the associated `Release Prep` issue
  - [ ] Close associated `Backport` issues
  - [ ] Open MR for the backport commits
  - [ ] Merge + Push
- [ ] Sign/Tag commit:
  - Tag : `tor-browser-$(RR_VERSION)-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(BUILD_N)`
  - Message: `Tagging $(BUILD_N) for $(RR_VERSION)-based (alpha|stable)`
- [ ] Push tag to origin

</details>

<details>
    <summary>Build/Signing/Publishing</summary>

### tor-browser-build: https://git.torproject.org/builders/tor-browser-build.git
Tor Browser Alpha (and Nightly) are on the `main` branch, while Stable lives in the various `$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-maint` (and possibly more specific) branches

- [ ] Update `rbm.conf`
    - [ ] `var/torbrowser_version` : update to next version
    - [ ] `var/torbrowser_build` : update to `$(TOR_BROWSER_BUILD_N)`
    - [ ] `var/torbrowser_incremental_from` : update to previous version
        - [ ] **IMPORTANT**: Really actually make sure this is the previous Desktop version or else the `make incrementals-*` step will fail
- [ ] Update `projects/firefox/config`
    - [ ] `git_hash` : update the `$(FIREFOX_BUILD_N)` section to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest $(ESR_VERSION) if rebased
- [ ] ***(Android Only)*** Update `projects/geckoview/config`
    - [ ] `git_hash` : update the `$(GECKOVIEW_BUILD_N)` section to match `geckoview` tag
    - [ ] ***(Optional)*** `var/geckoview_version` : update to latest `$(RR_VERSION)` if rebased
- [ ] ***(Android Only, Optional)*** Update `projects/tba-translations/config`:
  - [ ]  `git_hash` : update with HEAD commit of project's `fenix-torbrowserstringsxml` branch
- [ ] ***(Android Only, Optional)*** Update `projects/tor-android-service/config`
  - [ ] `git_hash` : update with HEAD commit of project's `master` branch
- [ ] ***(Android Only, Optionl)*** Update `projects/fenix/config`
  - [ ] `git_hash` : update the `$(FENIX_BUILD_N)` section to match `fenix` tag
  - [ ] ***(Optional)*** `var/fenix_version` : update to latest `$(RR_VERSION)` if rebased
- [ ] ***(Android Only)*** Update allowed_addons.json by running (from `tor-browser-build` root)`./tools/fetch_allowed_addons.py > projects/tor-browser/allowed_addons.json
- [ ] Check for NoScript updates here : https://addons.mozilla.org/en-US/firefox/addon/noscript
    - [ ] ***(Optional)*** If version available, update `noscript` section of `input_files` in `projects/browser/config`
        - [ ] `URL`
        - [ ] `sha256sum`
- [ ] Update the translation branches
  - [ ] Go to https://gitlab.torproject.org/tpo/translation/-/tree/base-browser/
  - [ ] Copy the hash of the last commit
  - [ ] Paste it into `projects/translation-base-browser/config`
- [ ] Check for openssl updates here : https://github.com/openssl/openssl/tags
    - [ ] ***(Optional)*** If new 1.X.Y series tag available, update `projects/openssl/config`
        - [ ] `version` : update to next 1.X.Y release tag
        - [ ] `input_files/sha256sum` : update to sha256 sum of source tarball
- [ ] Check for tor updates here : https://gitlab.torproject.org/tpo/core/tor/-/tags ; Tor Browser Alpha uses `-alpha` tagged tor, while stable uses the stable series
    - [ ] ***(Optional)*** If new tor version is available, update `projects/tor/config`
        - [ ] `version` : update to next release tag
- [ ] Check for go updates here : https://golang.org/dl (Tor Browser Alpha uses the latest Stable go version, while Tor Browser Stable uses the latest of the previous Stable major series version (eg: if Tor Browser Alpha is on the go1.17 series, Tor Browser Stable is on the go1.16 series)
    - [ ] ***(Optional)*** If new go version is available, update `projects/go/config`
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
- [ ] Begin build on `$(BUILD_SERVER)`
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
        - [ ] openssl
        - [ ] go
        - [ ] noscript
    - [ ] Convert ChangeLog.txt to markdown format used here by : `tor-browser-build/tools/changelog-format-blog-post`
- [ ] Push to origin as new branch, open 'Draft :' MR
- [ ] Remove draft from MR once signed-packages are uploaded
- [ ] Merge

### website: https://gitlab.torproject.org/tpo/web/tpo.git
- [ ] `databags/versions.ini` : Update the downloads versions
    - `torbrowser-stable/version` : sort of a catch-all for latest stable version
    - `torbrowser-stable/win32` : tor version in the expert bundle
    - `torbrowser-*-stable/version` : platform-specific stable versions
    - `torbrowser-*-alpha/version` : platform-specific alpha versions
    - `tor-stable`,`tor-alpha` : set by tor devs, do not touch
- [ ] Push to origin as new branch, open 'Draft :' MR
- [ ] Remove draft from MR once signed-packages are uploaded
- [ ] Merge

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
- [ ] ***(Android Only)*** : *TODO*
- [ ] run do-all-signing script:
    - `cd tor-browser-build/tools/signing/`
    - `./do-all-signing.sh`
- **NOTE**: at this point the signed desktop binaries should have been copied to `staticiforme`
- [ ] Update `staticiforme.torproject.org`:
  - From `screen` session on `staticiforme.torproject.org`
  - [ ] Static update components : `static-update-component cdn.torproject.org && static-update-component dist.torproject.org`
  - [ ] Enable update responses :
    - [ ] alpha: `./deploy_update_responses-alpha.sh`
    - [ ] release: `./deploy_update_responses-release.sh`
- [ ] ***(Android Only)*** : Publish APKs to Google Play
  - [ ] Log into https://play.google.com/apps/publish
  - Select correct app:
    - [ ] Tor Browser
    - [ ] Tor Browser Alpha
  - [ ] Navigate to `Release > Production` and click `Create new release` button
  - [ ] Upload the `*.multi.apk` APKs
  - [ ] If necessary, update the 'Release Name' (should be automatically populated)
  - [ ] Update Release Notes
    - [ ] Next to 'Release notes', click `Copy from a previous release`
    - [ ] Edit blog post url to point to most recent blog post
  - [ ] Save, review, and configure rollout percentage
    - [ ] 25% rollout when publishing a scheduled update
    - [ ] 100% rollout when publishing a security-driven release
  - [ ] ***Optional*** Update  rollout percentage to 100% after confirmed no major issues

### tor-announce mailing list
- [ ] ***(Stable release only)*** : send an email to tor-announce@lists.torproject.org, using the same content as the blog post and subject "Tor Browser $version is released".

</details>

/label ~"Release Prep"
