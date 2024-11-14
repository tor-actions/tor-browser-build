## Merge Info

<!-- Bookkeeping information for release management -->

### Issues

#### Resolves
- tor-browser-build#xxxxx
- tor-browser#xxxxx
- mullvad-browser#xxxxx

#### Related
- tor-browser-build#xxxxx
- tor-browser#xxxxx
- mullvad-browser#xxxxx

### Merging

<!-- This block tells the merger where commits need to be merged and future code archaeologists where commits were *supposed* to be merged -->

#### Target Branches
  - [ ] **`main`**: esr128-14.5
  - [ ] **`maint-14.0`**: esr128-14.0
  - [ ] **`maint-13.5`**: esr115-13.5

### Backporting

#### Timeline
- [ ] **No Backport (preferred)**: patchset for the next major stable
- [ ] **Immediate**: patchset needed as soon as possible
- [ ] **Next Minor Stable Release**: patchset that needs to be verified in nightly before backport
- [ ] **Eventually**: patchset that needs to be verified in alpha before backport

#### (Optional) Justification
- [ ] **Emergency security update**: patchset fixes CVEs, 0-days, etc
- [ ] **Censorship event**: patchset enables censorship circumvention
- [ ] **Critical bug-fix**: patchset fixes a bug in core-functionality
- [ ] **Consistency**: patchset which would make development easier if it were in both the alpha and release branches; developer tools, build system changes, etc
- [ ] **Sponsor required**: patchset required for sponsor
- [ ] **Other**: please explain

### Issue Tracking
- [ ] Link resolved issues with appropriate [Release Prep issue](https://gitlab.torproject.org/groups/tpo/applications/-/issues/?sort=updated_desc&state=opened&label_name%5B%5D=Release%20Prep&first_page_size=20) for changelog generation

### Review

#### Request Reviewer

- [ ] Request review from an applications developer depending on modified system:
  - **NOTE**: if the MR modifies multiple areas, please `/cc` all the relevant reviewers (since gitlab only allows 1 reviewer)
  - **accessibility** : henry
  - **android** : clairehurst, dan
  - **build system** : boklm
  - **extensions** : ma1
  - **firefox internals (XUL/JS/XPCOM)** : jwilde, ma1
  - **fonts** : pierov
  - **frontend (implementation)** : henry
  - **frontend (review)** : donuts, morgan
  - **localization** : henry, pierov
  - **macOS** : clairehurst, dan
  - **nightly builds** : boklm
  - **rebases/release-prep** : boklm, dan, ma1, morgan, pierov
  - **security** : jwilde, ma1
  - **signing** : boklm, morgan
  - **updater** : pierov
  - **windows** : jwilde, morgan
  - **misc/other** : morgan, pierov

#### Change Description

<!-- Whatever context the reviewer needs to effectively review the patchset; if the patch includes UX updates be sure to include screenshots/video of how any new behaviour -->

#### How Tested

<!-- Description of steps taken to verify the change -->
