This is the package we set as the macOS compiler.

It's a collection of macOS SDK, Clang, cctools, libtapi and LLVM runtimes.

# macOS SDK

We use the same SDK version as Firefox, and also Firefox's script to extract the
.pkg you can download from Apple servers (with a few changes to run them outside
Firefox's tree).

However, we mirror that .pkg source file because Apple might make it unavailable
without notice (the URL is probably the result of reverse engineering).

Anyway, we do not change the file we mirror in any way, so users can verify the
hash corresponds to the one that was at a certain point versioned in Firefox's
source code (in `taskcluster/ci/toolchain/macos-sdk.yml`).

# LLVM Runtimes

We follow the Firefox's `taskcluster/scripts/misc/build-llvm-common.sh` for the
various CMake options.
