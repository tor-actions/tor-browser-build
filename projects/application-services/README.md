Application Services is a collection of Rust components to enable integration
with Mozilla online services, such as the Mozilla account, sync, etc...

We do not fork this project, because we apply a minimal set of patches mainly
needed for offline builds.

References:

- [Documentation](https://mozilla.github.io/application-services/book/index.html)
- [Repository](https://github.com/mozilla/application-services)

# Dependencies

## Vendored Rust dependencies

Application Services is written mainly in Rust and it mnanages external
dependencies through cargo.
Reproduciblity is guaranteed by the provided `Cargo.lock`.

We run offline builds, so we create the dependency archive in a separate step
(`cargo_vendor`), implemented in `rbm.conf`.

When updating the project version, you should update also the expected hash of
the dependency archive.
You can create one with the `cargo_vendor-application-services` make target.

## Gradle dependencies

This repository also includes some plumbing/wrapping code to make the components
available to Java/Kotlin consumers.
Therefore, it has also several dependencies managed through Gradle.

Since our builds happen offline, we need to download the needed artifact before.
We keep the list of files to download in `gradle-dependencies-list.txt`.
A procedure to create this file is documented in
[tor-browser-build#40855](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40855#note_2906041).

## Other dependencies

Finally, Application Services depends on two C libraries:
[NSS](https://firefox-source-docs.mozilla.org/security/nss/index.html) and
[SQLCipher](https://www.zetetic.net/sqlcipher/).
We used to have separate tor-browser-build projects for them, but they were
almost an exact copy of the scripts included in this repository.
Keeping them updated wasn't trivial, so we decided to run Mozilla's scripts
instead.

# Caveats

## Git repository information

During the build, one of gradle scripts expects the git repository information
to be available, to include them in the output.

We pass the source code using `git archive`, so we lose this information.
Therefore, we patch said gradle script not to invoke git from the build script.

## `nimbus-fml`

Android Components and Fenix need the `nimbus-fml` binary and they download it
from some CDN.

Its source code is in this repository.
So, instead of downloading, we build it here and include it in the output
archive of this project.
