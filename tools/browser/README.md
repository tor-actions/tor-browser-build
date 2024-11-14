# Tools

### sign-tag

This script gpg signs a git tag associated with a particular browser commit in the user's tor-browser.git or mullvad-browser.git repo.

#### Prerequisites

- The user must create the following soft-links:
    - `/tools/browser/basebrowser` -> `/path/to/local/tor-browser.git`
    - `/tools/browser/mullvadbrowser` -> `/path/to/local/mullvad-browser.git`
    - `/tools/browser/torbrowser` -> `/path/to/local/tor-browser.git`
- The user must first checkout the relevant branch of the commit we are tagging
    - This is needed to extract the ESR version, branch-number, and browser name

#### Usage

```
usage: ./tools/browser/sign-tag.<browser> <channel> <build-number> [commit]

browser         one of basebrowser, torbrowser, or mullvadbrowser
channel         the release channel of the commit to sign (e.g. alpha, stable,
                or legacy)
build-number    the build number portion of a browser build tag (e.g. build2)
commit          optional git commit, HEAD is used if argument not present
```

#### Examples
Invoke the relevant soft-link'd version of this script to sign a particular browser. The trailing commit argument is optional and if not present, the browser branch's `HEAD` will be tagged+signed.

  - ##### `base-browser-128.4.0esr-14.5-1-build1`
    After checking out `base-browser-128.4.0esr-14.5-1` branch in linked tor-browser.git
    ```bash
    ./sign-tag.basebrowser alpha build1 24e628c1fd3f0593e23334acf55dc81909c30099
    ```
    **output**:
    ```
    Tag commit 24e628c1fd3f in base-browser-128.4.0esr-14.5-1
     tag:     base-browser-128.4.0esr-14.5-1-build1
     message: Tagging build1 for 128.4.0esr-based alpha
    ```

  - ##### `tor-browser-115.17.0esr-13.5-1-build2`
    After checking out `tor-browser-115.17.0esr-13.5-1` branch in linked tor-browser.git
    ```bash
    ./sign-tag.torbrowser legacy build2 8e9e58fe400291f20be5712d057ad0b5fc4d70c1
    ```
    **output**:
    ```
    Tag commit 8e9e58fe4002 in tor-browser-115.17.0esr-13.5-1
     tag:     tor-browser-115.17.0esr-13.5-1-build2
     message: Tagging build2 for 115.17.0esr-based legacy
    ```

  - ##### `mullvad-browser-128.4.0esr-14.0-1-build2`
    After checking out `mullvad-browser-128.4.0esr-14.0-1` branch in linked mullvad-browser.git
    ```bash
    ./sign-tag.mullvadbrowser stable build2 385aa0559a90a258ed6613527ff3e117dfa5ae5b
    ```
    **output**:
    ```
    Tag commit 385aa0559a90 in mullvad-browser-128.4.0esr-14.0-1
     tag:     mullvad-browser-128.4.0esr-14.0-1-build2
     message: Tagging build2 for 128.4.0esr-based stable
    ```