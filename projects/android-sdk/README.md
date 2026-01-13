This project contains some packages that would normally be installed with
`sdkmanager`, such as the build tools, platform tools and platforms.

It defines several environment variables that various build systems look for,
such as `ANDROID_HOME`.

We used to have a single package for the SDK and the NDK.
However, most of native binaries need only the NDK.
Therefore, we decided to split the project, to possibly reduce the iteration
time when updating the toolchains, as it is much easier to get the NDK right at
the first attempt.

# Known issues

## `failed to find target with hash string android-XY.1`

When adding `platform-36.1`, we encountered some build errors, and even
`sdkmanager` did not recognize it.

Our hypothesis is that some parts of the code expect an integer for the API
level, and `36.1` broke that assumption.

When you install parts of the SDK with `sdkmanager`, it adds a `package.xml`
file that is missing from the zip we download.
However, when this file is available, it is used as the authoritative reference.
Therefore, if you encounter a similar problem, you can install that package with
`sdkmanager`, then version the `package.xml` it creates and inject it in this
project.

## Refactor needed

Not all the included versions might be needed to build our projects.
So, this project could use a cleanup (tor-browser-build#41677).
