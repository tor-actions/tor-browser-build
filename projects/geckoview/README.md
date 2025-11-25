[GeckoView](https://mozilla.github.io/geckoview/) a Gecko-based WebView
alternative. It's built from the same code as Firefox, or, in our case, from
tor-browser.git.

# Custom ESR

Mozilla doesn't provide an ESR version for Firefox for Android, so it doesn't
provide one for GeckoView as well.
However, we decided to stay on the same version as desktop Firefox, and to
backport the Android security bugs from the rapid release.
Therefore, `geckoview` and `firefox` should always build from the same tree.

# "Fat" AARs

Theoretically, GeckoView is designed to be available also to products different
from Mozilla's browsers.
Therefore, Mozilla decided to
[provide a single AAR](https://bugzilla.mozilla.org/show_bug.cgi?id=1508976)
that targets all architectures, instead of one AAR for each architecture.

Unifying AARs is a separate step, with its own `mozconfig`.
Therefore, we do it in a separate step, that runs the `merge_aars` script.

Before Firefox 99, it was possible to use external AARs with the compile
environment turned off.
This configuration was not used by Mozilla and at a certain point they
[broke it](https://bugzilla.mozilla.org/show_bug.cgi?id=1763770).
The workaround is to use artifact builds, but we've never setup for our build
environment.
Instead, we've
[patched the build system](https://gitlab.torproject.org/tpo/applications/tor-browser/-/merge_requests/271/diffs?commit_id=b620f9a965b2030ccb3e45015867326a18eb9c33)
in tor-browser.git.

Notice that it isn't necessary to include all the architectures Mozilla and us
support (currently, aarch64, armv7 and x86_64).
The merge automation also supports "merging" one architecture.
We use this hack when `var/android_single_arch` is defined, which is the default
only in testbuilds.
The rationale is that we stay as close as possible to Mozilla for builds we
release to users, but we don't need to wait for all the architectures to build
for developer testbuilds.

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
