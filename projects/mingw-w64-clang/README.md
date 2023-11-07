This project builds a LLVM mingw toolchain and it's our default compiler for
Windows.

The only projects that still use the GCC toolchain are Rust and NSIS.

# Patches

We follow the same build steps as Mozilla.
We include also the same mingw patches.

See also `taskcluster/scripts/misc/build-clang-mingw.sh` on Firefox's source.

# libssp

libssp is no longer required to enable `_FORTIFY_SOURCE`.

However, some drivers expect to find a `libssp.a`, so we create an empty one,
like llvm-mingw.

References:

- [libssp is no longer required](https://www.msys2.org/news/#2022-10-10-libssp-is-no-longer-required)
- llvm-mingw's
  [commit fb67e16120b05c0664503b17532d5cc28c9cd1e9](https://github.com/mstorsjo/llvm-mingw/commit/fb67e16120b05c0664503b17532d5cc28c9cd1e9)
- [tor-browser-build#40652](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40652)

# Multiple architectures

We used to produce an artifact for i686 and another one for x86_64, just like we
do for the GCC toolchain.
However, Clang is very modular and the same binaries can target both the
architecture.

Also, Clang was the biggest part of the artifacts, in size.

Therefore, we decided to build both the 32-bit and the 64-bit and create a
single artifact, even for Mullvad Browser, which doesn't support 32-bit
architectures (in case we switch to 32-bit only NSIS).

See
[tor-browser-build#40832](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40832).

# Aliases

We add a few aliases from generic commands to LLVM tools. They include
`arch-w64-mingw32-cc` and `arch-w64-mingw32-cxx`, which might help to build some
projects that look either for `cc` or for `gcc`, but not for `clang`. 
