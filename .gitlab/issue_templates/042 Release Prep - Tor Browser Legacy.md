# 🧅 Release Prep Tor Browser Legacy

- **NOTE** It is assumed the `tor-browser` release rebase and security backport tasks have been completed

<details>
  <summary>Explanation of variables</summary>

- `${BUILD_SERVER}`: the server the main builder is using to build a browser release
- `${BUILDER}`: whomever is building the release on the ${BUILD_SERVER}
  - **example**: `pierov`
- `${STAGING_SERVER}`: the server the signer is using to run the signing process
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
  - **example**: `tor-browser-115.17.0esr-13.5-1-build1`
  - Run:
    ```bash
    ./tools/browser/sign-tag.torbrowser legacy ${BUILD_N}
    ```

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Tor Browser Legacy is on the `maint-13.5` branch

- [ ] Changelog bookkeeping:
  - Ensure all commits to `tor-browser` and `tor-browser-build` for this release have an associated issue linked to this release preparation issue
  - Ensure each issue has a platform (~Windows, ~MacOS, ~Desktop, ~"All Platforms") and potentially ~"Build System" labels
- [ ] Create a release preparation branch from the `maint-13.5` branch
- [ ] Run release preparation script:
  - **⚠️ WARNING**: You may need to manually update the `firefox/config` file's `browser_build` field if `tor-browser.git` has not yet been tagged (e.g. if security backports have not yet been merged and tagged)
  ```bash
  ./tools/relprep.py --tor-browser --date ${RELEASE_DATE} ${TOR_BROWSER_VERSION}
  ```
- [ ] Review build configuration changes:
  - [ ] `rbm.conf`
    - [ ] `var/torbrowser_version`: updated to next browser version
    - [ ] `var/torbrowser_build`: updated to `${TOR_BROWSER_BUILD_N}`
    - [ ] `var/browser_release_date`: updated to build date. For the build to be reproducible, the date should be in the past when building.
      - **⚠️ WARNING**: If we have updated `var/torbrowser_build` without updating the `firefox`, then we can leave this unchanged to avoid forcing a firefox re-build (e.g. when bumping `var/torbrwoser_build` to build2, build3, etc due to non-firefox related build issues)
    - [ ] ***(Desktop Only)*** `var/torbrowser_incremental_from`: updated to previous Desktop version
      - **NOTE**: We try to build incrementals for the previous 3 desktop versions
      - **⚠️ WARNING**: Really *actually* make sure this is the previous Desktop version or else the `make torbrowser-incrementals-*` step will fail
  - [ ] `projects/firefox/config`
    - [ ] `var/browser_build`: updated to match `tor-browser` tag
    - [ ] ***(Optional)*** `var/firefox_platform_version`: updated to latest `${ESR_VERSION}` if rebased
  - [ ] ***(Optional)*** `projects/translation/config`:
    - [ ] `steps/base-browser/git_hash`: updated with `HEAD` commit of project's `base-browser` branch
    - [ ] `steps/tor-browser/git_hash`: updated with `HEAD` commit of project's `tor-browser` branch
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
    - **NOTE**: Only if new tag available
    - [ ] `version`: updated to next release tag
    - [ ] `git_hash`: updated to the commit corresponding to the tag (we don't check signatures for Zstandard)
  - [ ] **(Optional)** `projects/tor/config` https://gitlab.torproject.org/tpo/core/tor/-/tags
    - [ ] `version`: updated to latest non `-alpha` tag or release tag if newer (ping **dgoulet** or **ahf** if unsure)
  - [ ] **(Optional)** `projects/go/config` https://go.dev/dl
    - [ ] `go_1_22`: updated to latest 1.22 version
    - [ ] `input_files/sha256sum` for `go`: update sha256sum of archive (sha256 sums are displayed on the go download page)
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
    - No Android updates
    - All issues added under correct platform
    - ESR updates correct
    - Component updates correct
- [ ] Open MR with above changes, using the template for release preparations
  - **NOTE**: target the `maint-13.5` branch
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
    - [ ] Tor Project build machine
    - [ ] Local developer machine
  - [ ] Submit build request to Mullvad infrastructure:
    - **NOTE** this requires a github authentication token
    - Run:
      ```bash
      make torbrowser-kick-devmole-build
      ```

</details>

<details>
  <summary>Website</summary>

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
- [ ] On `${STAGING_SERVER}`, ensure updated:
  - **NOTE** Having a local git branch with `maint-13.5` as the upstream branch with these values saved means you only need to periodically `git pull --rebase` and update the `set-config.tbb-version` file
  - [ ] `tor-browser-build` is on the right commit: `git tag -v tbb-${TOR_BROWSER_VERSION}-${TOR_BROWSER_BUILD_N} && git checkout tbb-${TOR_BROWSER_VERSION}-${TOR_BROWSER_BUILD_N}`
  - [ ] `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_builder`: ssh hostname of machine with unsigned builds
    - `ssh_host_linux_signer`: ssh hostname of linux signing machine
    - `builder_tor_browser_build_dir`: path on `ssh_host_builder` to root of builder's `tor-browser-build` clone containing unsigned builds
  - [ ] `tor-browser-build/tools/signing/set-config.rcodesign-appstoreconnect`
    - `appstoreconnect_api_key_path`: path to json file containing appstoreconnect api key infos
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
- [ ] Deploy `tor-blog` MR
- [ ] On `staticiforme.torproject.org`, remove old release:
  - **NOTE**: Skip this step if we need to hold on to older versions for some reason (for example, this is an Andoid or Desktop-only release, or if we need to hold back installers in favor of build-to-build updates if there are signing issues, etc)
  - [ ] `/srv/cdn-master.torproject.org/htdocs/aus1/torbrowser`
  - [ ] `/srv/dist-master.torproject.org/htdocs/torbrowser`
  - Run:
    ```bash
    static-update-component cdn.torproject.org && static-update-component dist.torproject.org
    ```
- [ ] **(Optional)** Generate and deploy new update responses
  - **NOTE**: This is only required if there will be no corresponding 15.0 release (i.e. this is an emergency legacy-only 13.5 release). Normally, legacy update responses are generated and deployed as part of the 15.0 release.
  - **⚠️ WARNING**: This is a little bit off the beaten track, ping boklm or morgan if you have any doubts
  - From the `maint-15.0` branch:
    - [ ] Update `rbm.conf`
      - [ ] `var/torbrowser_legacy_version`: update to `${TOR_BROWSER_VERSION}`
        - **NOTE** this is the browser version for the legacy branch, not this stable branch we've switched to
      - [ ] `var/torbrowser_legacy_platform_version`: update to `${ESR_VERSION}`
        - **NOTE** this is ESR version for the legacy branch, not this stable branch we've switched to
    - [ ] Generate update responses and commit them to tor-browser-update-responses.git:
      - Run:
        ```bash
        cd tor-browser-build/tools/signing/ && ./deploy-legacy
        ```
  - On `staticiforme.torproject.org`, deploy new update responses:
    - [ ] Enable update responses, passing the commit hash as argument (replace $commit):
      ```bash
      sudo -u tb-release ./deploy_update_responses-release.sh $commit
      ```

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
    New Release: Tor Browser ${TOR_BROWSER_VERSION} (Windows, macOS)
    ```
  - **Body**
    ```
    Hi everyone,

    Tor Browser ${TOR_BROWSER_VERSION} has now been published for legacy Windows and macOS platforms. For details please see our blog post:
    - ${BLOG_POST_URL}

    Changelog:
    # paste changelog as quote here
    ```

</details>

/label ~"Apps::Type::ReleasePreparation"
/label ~"Apps::Impact::High"
/label ~"Priority::Blocker"
/label ~"Apps::Product::TorBrowser"
