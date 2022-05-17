<details>
  <summary>Explanation of variables</summary>

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
  -  [ ] Commit with message `Translation updates
     - **NOTE** : only add files which are already being tracked
  -  [ ] *(Optional)* Backport to maintenance branch if present
- [ ] fixup! `tor-browser`'s `Bug 10760 : Integrate TorButton to TorBrowser core` issue to point to updated `torbutton` commit

### **tor-launcher** ***(Optional)***: https://git.torproject.org/tor-launcher.git
- [ ] ***(Optional)*** Update translations:
  - **NOTE** : mandatory if we have added new string dependencies
  - [ ] ./localization/import-translations.sh
- [ ] Update `install.rdf` file with new version
- [ ] Sign/Tag commit :
    - Tag : `$(TOR_LAUNCHER_VERSION)`
    - Message `Tagging $(TOR_LAUNCHER_VERSION)`
- [ ] Push `master` and tag to origin

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
- [ ] _TODO: tag base firefox no-tor browser_
- [ ] ***(Optional)*** Backport any required patches to Stable
    - [ ] cherry-pick patches on top of rebased branch (issues to backport should have `Backport` label and be linked to the associated `Release Prep` issue
    - [ ] Close associated `Backport` issues
    - [ ] Open MR for the backport commits
- [ ] Sign/Tag commit :
    - Tag : `tor-browser-$(ESR_VERSION)esr-$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-1-$(FIREFOX_BUILD_N)`
    - Message : `Tagging $(FIREFOX_BUILD_N) for $(ESR_VERSION)esr-based (alpha|stable)`
- [ ] Push tag to origin

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
_TODO_

### **android-components** ***(Optional)***: https://gitlab.torproject.org/tpo/applications/android-components.git
_TODO_

### **tor-android-service** ***(Optional)***: https://git.torproject.org/tor-android-service.git
_TODO_

### **fenix** ***(Optional)***: https://gitlab.torproject.org/tpo/applications/fenix.git
_TODO_

</details>

<details>
    <summary>Build/Signing/Publishing</summary>

### tor-browser-build: https://git.torproject.org/builders/tor-browser-build.git
Tor Browser Alpha (and Nightly) are on the `master` branch, while Stable lives in the various `$(TOR_BROWSER_MAJOR).$(TOR_BROWSER_MINOR)-maint` (and possibly more specific) branches

- [ ] Update `rbm.conf`
    - [ ] `var/torbrowser_version` : update to next version
    - [ ] `var/torbrowser_build` : update to `$(TOR_BROWSER_BUILD_N)`
    - [ ] `var/torbrowser_incremental_from` : update to previous version
        - [ ] **IMPORTANT**: Really actually make sure this is the previous Desktop/Android version or else the `make incrementals-*` step will fail
- [ ] Update `projects/firefox/config`
    - [ ] `git_hash` : update the $(FIREFOX_BUILD_N) section to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version` : update to latest $(ESR_VERSION) if rebased
- [ ] Check for NoScript updates here : https://addons.mozilla.org/en-US/firefox/addon/noscript
    - [ ] ***(Optional)*** If version available, update `noscript` section of `input_files` in `projects/tor-browser/config`
        - [ ] `URL`
        - [ ] `sha256sum`
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
- [ ] ***(Android Only)*** Update allowed_addons.json by running (from `tor-browser-build` root)`./tools/fetch_allowed_addons.py > projects/tor-browser/allowed_addons.json
- [ ] Update `ChangeLog.txt`
- [ ] Open MR with above changes
- [ ] Begin build on `tb-build-03`
- [ ] Sign/Tag commit : `make signtag-(alpha|release)`
- [ ] Push tag to origin

### notify tor-qa
- [ ] Email tor-qa@lists.torproject.org
    - [ ] Provide links to unsigned builds on `tb-build-03`
    - [ ] Call out any new funcionality which needs testing
    - [ ] Link to any known issues

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

### website: https://gitlab.torproject.org/tpo/web/tpo.git
- [ ] `databags/versions.ini` : Update the downloads versions
    - `torbrowser-stable/version` : sort of a catch-all for latest stable version
    - `torbrowser-stable/win32` : tor version in the expert bundle
    - `torbrowser-*-stable/version` : platform-specific stable versions
    - `torbrowser-*-alpha/version` : platform-specific alpha versions
    - `tor-stable`,`tor-alpha` : set by tor devs, do not touch
- [ ] Push to origin as new branch, open 'Draft :' MR
- [ ] Remove draft from MR once signed-packages are uploaded

### signing
_TODO: boklm's fancy new signing+uploading scripts_

</details>

/label ~"Release Prep"