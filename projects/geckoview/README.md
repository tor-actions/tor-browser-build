[GeckoView](https://mozilla.github.io/geckoview/) a Gecko-based WebView
alternative. It's built from the same code as Firefox, or, in our case, from
tor-browser.git.

# Custom ESR

Mozilla doesn't provide an ESR version of Firefox for Android, so it doesn't
provide one for GeckoView as well.
However, we decided to stay on the same version as desktop Firefox, and to
backport the Android security bugs from the rapid release.
Therefore, `geckoview` and `firefox` should always build from the same tree.

# Build steps

At a certain point, Mozilla migrated Android frontend code (_Fenix_) to
mozilla-central. Therefore, we now use only tor-browser.git.

The build steps are:

1. Build GeckoView for each architecture
2. Merge the various architecture into a single "fat" AAR
3. Build Android Components
4. Build Fenix

We run 1. in a dedicated step (`build`), since it's architecture-specific, then
we run the rest in a single RBM step (`build_apk`).

We had to
[patch the build system](https://gitlab.torproject.org/tpo/applications/tor-browser/-/merge_requests/271/diffs?commit_id=b620f9a965b2030ccb3e45015867326a18eb9c33)
in tor-browser.git to make this possible, as upstream relies on artifact builds
for this.
Instead, we disable the compile environment.

Notice that it isn't necessary to include all the architectures Mozilla and us
support (currently, aarch64, armv7 and x86_64).
We do it to stay as close as possible to Mozilla for builds we release to users,
but we do single-architecture builds in testbuilds, to reduce the time to make
them.

# Java dependencies

While GeckoView shares a lot of code with Firefox and also provides a
`libxul.so`, it also has some Java code to allow Android app developers to
interact with it easily.

Therefore, it also has some third party dependencies that aren't vendored like
the majority of other Firefox dependencies, but they are fetched by Gradle
automatically at build time.

Our builds are run offline and we tightly control the inputs for reproducibility
purposes.
The list of Java dependencies is versioned in `gradle-dependencies-list.txt`.
The easiest way we found to get it is to run an online build once, and check
what Gradle downloaded after the fact.
More details on a way to do it are documented in
[tor-browser-build#40855](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40855#note_2906041).

# Mozconfig customization

For Android, the majority of `mozconfig` customization is versioned in
`tor-browser.git`.

The only additional information we add in the build scripts are the commit hash
we used for the build (to make it appear in `about:buildconfig`) and the channel
of the build.
