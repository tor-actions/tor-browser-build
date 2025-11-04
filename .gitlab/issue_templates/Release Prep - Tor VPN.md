# Release Prep Tor VPN

- **NOTE** It is assumed the `vpn` release has been tagged in the `vpn.git` repository

<details>
  <summary>Explanation of variables</summary>

- `${STAGING_SERVER}`: the server the signer is using to run the signing process
- `${TOR_VPN_VERSION}`: the Tor VPN version
  - **example**: `1.3.0Beta`
- `${TOR_VPN_BUILD_N}`: the torvpn build revision for a given Tor VPN release; used in tagging git commits
  - **example**: `build1`

</details>

<details>
  <summary>Build Configuration</summary>

### tor-browser-build: https://gitlab.torproject.org/tpo/applications/tor-browser-build.git
Tor VPN is on the `main` branch

- [ ] Create a release preparation branch from the current `main` branch
- Edit `rbm.conf`, updating the following:
  - [ ] `targets/torvpn/var/torbrowser_version`: updated to next torvpn version (`${TOR_VPN_VERSION}`)
  - [ ] `targets/torvpn/var/torbrowser_build`: updated to `${TOR_VPN_BUILD_N}` (usually `build1`)
  - [ ] `targets/torvpn/var/browser_release_date`: updated to build date. For the build to be reproducible, the date should be in the past when building.
- [ ] Open MR with above changes.
  - **NOTE**: target the `main` branch
- [ ] Merge

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
- Place the Tor VPN release to be signed in directory `torvpn/alpha/signed/${TOR_VPN_VERSION}`:
  - [ ] `mkdir torvpn/alpha/signed/${TOR_VPN_VERSION} && cd torvpn/alpha/signed/${TOR_VPN_VERSION}`
  - [ ] `wget https://${URL_PATH}/app-release.aab` (replacing `${URL_PATH}` with the location where the unsigned build has been published)
  - [ ] `mv app-release.aab tor-vpn-${TOR_VPN_VERSION}.aab`
  - [ ] `wget https://${URL_PATH}/app-release-unsigned.apk` (replacing `${URL_PATH}` with the location where the unsigned build has been published)
  - [ ] `mv app-release-unsigned.apk tor-vpn-qa-unsigned-android-multiarch-${TOR_VPN_VERSION}.apk`
  - [ ] `sha256sum tor-vpn-* > sha256sums-unsigned-build.txt`
  - [ ] Compare checksums from `sha256sums-unsigned-build.txt` with expected checksums
- [ ] On `${STAGING_SERVER}`, ensure updated:
  - [ ] `tor-browser-build` is on the right commit
  - [ ] `tor-browser-build/tools/signing/set-config.hosts`
    - `ssh_host_linux_signer`: ssh hostname of linux signing machine
- [ ] On `${STAGING_SERVER}` in a separate `screen` session, run do-all-signing script:
  - Run:
    ```bash
    cd tor-browser-build/tools/signing/ && ./do-all-signing.torvpn
    ```
  - **NOTE**: on successful execution, the signed binaries should have been copied to `staticiforme`.

</details>

<details>
  <summary>Publishing</summary>

### dist.torproject.org
- [ ] On `staticiforme.torproject.org`, static update components:
  - Run:
    ```bash
    static-update-component dist.torproject.org
    ```
- [ ] On `staticiforme.torproject.org`, remove old release:
  - **NOTE**: Skip this step if we need to hold on to older versions for some reason.
  - [ ] `/srv/dist-master.torproject.org/htdocs/torvpn`
  - Run:
    ```bash
    static-update-component dist.torproject.org
    ```

### Google Play: https://play.google.com/apps/publish
- [ ] Publish AAB to Google Play:
  - Select `Tor VPN` app
  - Navigate to `Test and release > Internal testing` and click `Create new release` button:
    - Upload the `tor-vpn-$version.aab` file
    - Update Release Notes using the changenotes from donuts from the release issue
  - Publish
  - Promote to closed and open testing

</details>

/label ~"Apps::Type::ReleasePreparation"
/label ~"Apps::Impact::High"
/label ~"Priority::Blocker"
/label ~"Apps::Product::TorVPN"
