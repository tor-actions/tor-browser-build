In this project we create an archive with the tor binary and the binaries of the
various pluggable transports for each platform.

We consume them in the `browser` project for desktop and in the Android-specific
projects, but we also include them in our distribution directory, so that users
interested in pre-built binaries but not in Tor Browser can use them without
downloading the full packages.
