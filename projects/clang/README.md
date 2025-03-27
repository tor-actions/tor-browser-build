This is the Clang compiler.

For Linux and Android, we use it only to build Firefox and GeckoView, but we do
not use this project directly. Instead, we use `clang-linux`,
that adds platform-specific libraries and tools.
For Windows and macOS, we use it to build everything, but we also do not use this
project directly. Instead, we use `mingw-w64-clang` and `macosx_toolchain`, that
also add platform-specific libraries and tools.

# Caveats

## Version

We use the same version of LLVM as Firefox.
You can cross-reference `taskcluster/ci/toolchain/clang.yml` and
`taskcluster/ci/fetch/toolchains.yml` to get the exact git tree.
However, since we need to use the LLVM source in several projects and its
repository is quite big, we fetch it in the `llvm-project` project.

## Configuration options

As for the configuration options, we do not follow exactly the same as Firefox.
We define some additional ones for our purposes (e.g., we define
`LLVM_INSTALL_UTILS` to avoid building another copy of LLVM when building the
Rust compiler).

## Duplicated outputs

We use the same options to build Clang for all our platforms.

However, we have different steps to produce the containers we use for each
platform.
As a result, the builds have a different `var/buildid`, but Android, macOS and
Windows binaries are exactly the same (Linux uses an older version of Debian to
maximize binary compatibility).
