# Release Prep Tor Browser Stable

- **NOTE** It is assumed the `tor-browser` release rebase and security backport tasks have been completed
- **NOTE** This can/is often done in conjunction with the equivalent Mullvad Browser release prep issue

<details>
  <summary>Explanation of variables</summary>

- `${BUILD_SERVER}`: the server the main builder is using to build a browser release
- `${BUILDER}`: whomever is building the release on the ${BUILD_SERVER}
  - **example**: `pierov`
- `${STAGING_SERVER}`: the server the signer is using to to run the signing process
- `${ESR_VERSION}`: the Mozilla defined ESR version, used in various places for building browser tags, labels, etc
  - **example**: `91.6.0`
- `${TOR_BROWSER_MAJOR}`: the Tor Browser major version
  - **example**: `11`
- `${TOR_BROWSER_MINOR}`: the Tor Browser minor version
  - **example**: either `0` or `5`; Alpha's is always `(Stable + 5) % 10`
- `${TOR_BROWSER_VERSION}`: the Tor Browser version in the format
  - **example**: `12.5a3`, `12.0.3`
- `${BUILD_N}`: a project's build revision within a its branch; this is separate from the `${TOR_BROWSER_BUILD_N}` value; many of the Firefox-related projects have a `${BUILD_N}` suffix and may differ between projects even when they contribute to the same build.
  - **example**: `build1`
- `${TOR_BROWSER_BUILD_N}`: the tor-browser build revision for a given Tor Browser release; used in tagging git commits
  - **example**: `build2`
  - **⚠️ WARNING**: A project's `${BUILD_N}` and `${TOR_BROWSER_BUILD_N}` may be the same, but it is possible for them to diverge. For example :
    - if we have multiple Tor Browser releases on a given ESR branch the two will become out of sync as the `${BUILD_N}` value will increase, while the `${TOR_BROWSER_BUILD_N}` value may stay at `build1` (but the `${TOR_BROWSER_VERSION}` will increase)
    - if we have build failures unrelated to `tor-browser`, the `${TOR_BROWSER_BUILD_N}` value will increase while the `${BUILD_N}` will stay the same.
- `${TOR_BROWSER_VERSION}`: the published Tor Browser version
    - **example**: `11.5a6`, `11.0.7`
- `${TBB_BUILD_TAG}`: the `tor-browser-build` build tag used to build a given Tor Browser version
  - **example**: `tbb-12.5a7-build1`
- `${RELEASE_DATE}`: the intended release date of this browser release; for ESR schedule-driven releases, this should match the upstream Firefox release date
  - **example**: `2024-10-29`

</details>

<details>
  <summary>Build Configuration</summary>

### tor-browser: https://gitlab.torproject.org/tpo/applications/tor-browser.git

- [ ] Tag `tor-browser` in tor-browser.git
  - **example**: `tor-browser-128.4.0esr-14.0-1-build1`
  - Run:
    ```bash
    ./tools/browser/sign-tag.torbrowser stable ${BUILD_N}
    ```

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Tor Browser Stable is on the `maint-${TOR_BROWSER_MAJOR}.${TOR_BROWSER_MINOR}` branch

- [ ] Changelog bookkeeping:
  - Ensure all commits to `tor-browser` and `tor-browser-build` for this release have an associated issue linked to this release preparation issue
  - Ensure each issue has a platform (~Windows, ~MacOS, ~Linux, ~Android, ~Desktop, ~"All Platforms") and potentially ~"Build System" labels
- [ ] Create a release preparation branch from the current `maint-XX.Y` branch
- [ ] Run release preparation script:
  - **NOTE**: You can omit the `--tor-browser` argument if this is for a joint Tor and Mullvad Browser release
  - **⚠️ WARNING**: You may need to manually update the `firefox/config` and `geckoview/config` files' `browser_build` field if `tor-browser.git` has not yet been tagged (e.g. if security backports have not yet been merged and tagged)
  ```bash
  ./tools/relprep.py --tor-browser --date ${RELEASE_DATE} ${TOR_BROWSER_VERSION}
  ```
- [ ] Review build configuration changes:
  - [ ] `rbm.conf`
    - [ ] `var/torbrowser_version`: updated to next browser version
    - [ ] `var/torbrowser_build`: updated to `${TOR_BROWSER_BUILD_N}`
    - [ ] `var/browser_release_date`: updated to build date. For the build to be reproducible, the date should be in the past when building.
      - **⚠️ WARNING**: If we have updated `var/torbrowser_build` without updating the `firefox` or `geckoview` tags, then we can leave this unchanged to avoid forcing a firefox re-build (e.g. when bumping `var/torbrwoser_build` to build2, build3, etc due to non-firefox related build issues)
    - [ ] ***(Desktop Only)*** `var/torbrowser_incremental_from`: updated to previous Desktop version
      - **NOTE**: We try to build incrementals for the previous 3 desktop versions
      - **⚠️ WARNING**: Really *actually* make sure this is the previous Desktop version or else the `make torbrowser-incrementals-*` step will fail
    - [ ] `var/torbrowser_legacy_version`: updated to latest legacy Tor Browser version
    - [ ] `var/torbrowser_legacy_platform_version`: updated to latest legacy Tor Browser ESR version
  - [ ] `projects/firefox/config`
      - [ ] `var/browser_build`: updated to match `tor-browser` tag
      - [ ] ***(Optional)*** `var/firefox_platform_version`: updated to latest `${ESR_VERSION}` if rebased
  - [ ] `projects/geckoview/config`
    - [ ] `var/browser_build`: updated to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version`: updated to latest `${ESR_VERSION}` if rebased
  - [ ] ***(Optional)*** `projects/translation/config`:
    - [ ] `steps/base-browser/git_hash`: updated with `HEAD` commit of project's `base-browser` branch
    - [ ] `steps/tor-browser/git_hash`: updated with `HEAD` commit of project's `tor-browser` branch
    - [ ] `steps/fenix/git_hash`: updated with `HEAD` commit of project's `fenix-torbrowserstringsxml` branch
  - [ ] ***(Optional)*** `projects/browser/config`:
    - [ ] ***(Optional)*** NoScript: https://addons.mozilla.org/en-US/firefox/addon/noscript
      - [ ] `URL` updated
        - **⚠️ WARNING**: If preparing the release manually, updating the version number in the url is not sufficient, as each version has a random unique id in the download url
      - [ ] `sha256sum` updated
  - [ ] ***(Optional)*** `projects/openssl/config`: https://www.openssl.org/source/
    - **NOTE**: Only if new LTS version (3.0.X currrently) available
    - [ ] `version`: updated to next LTS version
    - [ ] `input_files/sha256sum`: updated to sha256 sum of source tarball
  - [ ] **(Optional)** `projects/zlib/config`: https://github.com/madler/zlib/releases
    - **NOTE**: Only if new tag available
    - [ ] `version`: updated to next release tag
  - [ ] **(Optional)** `projects/zstd/config`: https://github.com/facebook/zstd/releases
    - **NOTE**: Only if new tag available; Android-only for now
    - [ ] `version`: updated to next release tag
    - [ ] `git_hash`: updated to the commit corresponding to the tag (we don't check signatures for Zstandard)
  - [ ] **(Optional)** `projects/tor/config` https://gitlab.torproject.org/tpo/core/tor/-/tags
    - [ ] `version`: updated to latest non `-alpha` tag or release tag if newer (ping **dgoulet** or **ahf** if unsure)
  - [ ] **(Optional)** `projects/go/config` https://go.dev/dl
    - **NOTE**: In general, Tor Browser Alpha uses the latest Stable major series Go version, but there are sometimes exceptions. Check with the anti-censorship team before doing a major version update in case there is incompatibilities.
    - [ ] `version`: updated go version
    - [ ] `var/source_sha256sum for `go`: update sha256sum of archive (sha256 sums are displayed on the go download page)
  - [ ] **(Optional)** `projects/manual/config`
    - [ ] `version`: updated to latest pipeline id
    - [ ] `input_files/shasum` for `manual`: updated to manual hash
    - [ ] Upload the downloaded `manual_${PIPELINEID}.zip` file to `tb-build-02.torproject.org`
    - [ ] Deploy to `tb-builder`'s `public_html` directory:
      - Run:
        ```bash
        sudo -u tb-builder cp manual_${PIPELINEID}.zip ~tb-builder/public_html/.
        ```
      - `sudo` documentation for TPO machines: https://gitlab.torproject.org/tpo/tpa/team/-/wikis/doc/accounts#changingresetting-your-passwords
  - [ ] `ChangeLog-TBB.txt`: ensure correctness
    - Browser name correct
    - Release date correct
    - No Android updates on a desktop-only release and vice-versa
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
    make torbrowser-signtag-release
    ```
- [ ] Push tag to `upstream`
- [ ] Build the tag:
  - Run:
    ```bash
    make torbrowser-release && make torbrowser-incrementals-release
    ```
    - Tor Project build machine
    - Local developer machine
  - [ ] Submit build request to Mullvad infrastructure:
    - **NOTE** this requires a github authentication token
    - Run:
      ```bash
      make torbrowser-kick-devmole-build
      ```

</details>

<details>
  <summary>Website</summary>

  ### downloads: https://gitlab.torproject.org/tpo/web/tpo.git
  - [ ] `databags/versions.ini`: Update the downloads versions
      - `torbrowser-stable/version`: catch-all for latest stable version
      - `torbrowser-alpha/version`: catch-all for latest alpha version
      - `torbrowser-*-stable/version`: platform-specific stable versions
      - `torbrowser-*-alpha/version`: platform-specific alpha versions
  - [ ] Push to origin as new branch and create MR
  - [ ] Review
  - [ ] Merge
    - **⚠️ WARNING**: Do not deploy yet!

  ### blog: https://gitlab.torproject.org/tpo/web/blog.git
  - [ ] Generate release blog post
    - Run:
    ```bash
    ./tools/signing/create-blog-post.torbrowser
    ```
    - **NOTE** this script creates the new blog post from a template (edit `./tools/signing/set-config.blog` to set you local blog directory)
    - [ ] **(Optional)** Note any ESR update
    - [ ] **(Optional)** Thank any users which have contributed patches
    - [ ] **(Optional)** Draft any additional sections for new features which need testing, known issues, etc
  - [ ] Push to origin as new branch and open MR
  - [ ] Review
  - [ ] Merge
    - **⚠️ WARNING**: Do not deploy yet!

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
- [ ] Notify Tails
  - **Recipients**
    ```
    tails-dev@boum.org
    ```
  - **Subject**
    ```
    Tor Browser ${TOR_BROWSER_VERSION} Ready
    ```
  - **Body**
    ```
    Hello,

    Tor Browser Stable is ready for Tails. Build artifacts can be found here:
    - ${BUILD_ARTIFACTS_URL}

    Changelog:
    # paste changelog as quote here
    ```
- [ ] Verify the associated legacy `maint-13.5` release has been signed and deployed
  - **⚠️ WARNING**: Do not continue if the legacy channel has not been fully signed and published yet; it is needed for update-response generation!
  - **NOTE** Stable releases without a corresponding legacy release may ignore this
- [ ] On `${STAGING_SERVER}`, ensure updated:
  - **NOTE** Having a local git branch with `maint-14.5` as the upstream branch with these values saved means you only need to periodically `git pull --rebase` and update the `set-config.tbb-version` file
  - [ ] `tor-browser-build` is on the right commit: `git tag -v tbb-${TOR_BROWSER_VERSION}-${TOR_BROWSER_BUILD_N} && git checkout tbb-${TOR_BROWSER_VERSION}-${TOR_BROWSER_BUILD_N}`
  - [ ] `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_builder`: ssh hostname of machine with unsigned builds
    - `ssh_host_linux_signer`: ssh hostname of linux signing machine
    - `builder_tor_browser_build_dir`: path on `ssh_host_builder` to root of builder's `tor-browser-build` clone containing unsigned builds
  - [ ] `tor-browser-build/tools/signing/set-config.rcodesign-appstoreconnect`
    - `appstoreconnect_api_key_path`: path to json file containing appstoreconnect api key infos
  - [ ] `set-config.update-responses`
    - `update_responses_repository_dir`: directory where you cloned `git@gitlab.torproject.org:tpo/applications/tor-browser-update-responses.git`
  - [ ] `tor-browser-build/tools/signing/set-config.tbb-version`
    - `tbb_version`: tor browser version string, same as `var/torbrowser_version` in `rbm.conf` (examples: `11.5a12`, `11.0.13`)
    - `tbb_version_build`: the tor-browser-build build number (if `var/torbrowser_build` in `rbm.conf` is `buildN` then this value is `N`)
    - `tbb_version_type`: either `alpha` for alpha releases or `release` for stable releases
- [ ] On `${STAGING_SERVER}` in a separate `screen` session, ensure tor daemon is running with SOCKS5 proxy on the default port 9050
- [ ] On `${STAGING_SERVER}` in a separate `screen` session, run do-all-signing script:
  - Run:
    ```bash
    cd tor-browser-build/tools/signing/ && ./do-all-signing.torbrowser
    ```
  - **NOTE**: on successful execution, the signed binaries and mars should have been copied to `staticiforme` and update responses pushed

</details>

<details>
  <summary>Signature verification</summary>

  <details>
    <summary>Check whether the .exe files got properly signed and timestamped</summary>

```bash
# Point OSSLSIGNCODE to your osslsigncode binary
pushd tor-browser-build/torbrowser/${channel}/signed/$TORBROWSER_VERSION
OSSLSIGNCODE=/path/to/osslsigncode
../../../../tools/authenticode_check.sh
popd
```

  </details>
  <details>
    <summary>Check whether the MAR files got properly signed</summary>

```bash
# Point NSSDB to your nssdb containing the mar signing certificate
# Point SIGNMAR to your signmar binary
# Point LD_LIBRARY_PATH to your mar-tools directory
pushd tor-browser-build/torbrowser/${channel}/signed/$TORBROWSER_VERSION
NSSDB=/path/to/nssdb
SIGNMAR=/path/to/mar-tools/signmar
LD_LIBRARY_PATH=/path/to/mar-tools/
../../../../tools/marsigning_check.sh
popd
```

  </details>
</details>

<details>
  <summary>Publishing</summary>

### website
- [ ] On `staticiforme.torproject.org`, static update components:
  - Run:
    ```bash
    static-update-component cdn.torproject.org && static-update-component dist.torproject.org
    ```
- [ ] Deploy `tor-website` MR
- [ ] Deploy `tor-blog` MR
- [ ] On `staticiforme.torproject.org`, enable update responses:
  - Run:
    ```bash
    sudo -u tb-release ./deploy_update_responses-release.sh
    ```
- [ ] On `staticiforme.torproject.org`, remove old release:
  - **NOTE**: Skip this step if we need to hold on to older versions for some reason (for example, this is an Andoid or Desktop-only release, or if we need to hold back installers in favor of build-to-build updates if there are signing issues, etc)
  - [ ] `/srv/cdn-master.torproject.org/htdocs/aus1/torbrowser`
  - [ ] `/srv/dist-master.torproject.org/htdocs/torbrowser`
  - Run:
    ```bash
    static-update-component cdn.torproject.org && static-update-component dist.torproject.org
    ```

### Google Play: https://play.google.com/apps/publish
- [ ] Publish APKs to Google Play:
  - Select `Tor Browser` app
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

</details>

<details>
  <summary>Communications</summary>

### tor-announce mailing list
- [ ] Email tor-announce mailing list
  - **Recipients**
    ```
    tor-announce@lists.torproject.org
    ```
  - **Subject**
    ```
    New Release: Tor Browser ${TOR_BROWSER_VERSION} (Android, Windows, macOS, Linux)
    ```
  - **Body**
    ```
    Hi everyone,

    Tor Browser ${TOR_BROWSER_VERSION} has now been published for all platforms. For details please see our blog post:
    - ${BLOG_POST_URL}

    Changelog:
    # paste changelog as quote here
    ```

### packagers
- [ ] Email packagers:
  - **Recipients**
    - Guardian Project: nathan@guardianproject.info
    - FreeBSD port: freebsd@sysctl.cz <!-- Gitlab user maxfx -->
    - OpenBSD port: caspar@schutijser.com <!-- Gitlab user cschutijser -->
    - torbrowser-launcher: mail@asciiwolf.com <!-- Gitlab user asciiwolf -->
    - Anti-Censorship: meskio@torproject.org <!-- Gitlab user meskio -->
    ```
    nathan@guardianproject.info, freebsd@sysctl.cz, caspar@schutijser.com, mail@asciiwolf.com, meskio@torproject.org,
    ```
  - **Subject**
    ```
    New Release: Tor Browser ${TOR_BROWSER_VERSION} (Android, Windows, macOS, Linux)
    ```
  - **Body**
    ```
    Hi everyone,

    Tor Browser ${TOR_BROWSER_VERSION} has now been published for all platforms. For details please see our blog post:
    - ${BLOG_POST_URL}

    Changelog:
    # paste changelog as quote here
    ```
  - [ ] Note any changes which may affect packaging/downstream integration
</details>

/label ~"Apps::Type::ReleasePreparation"
/label ~"Apps::Product::TorBrowser"
