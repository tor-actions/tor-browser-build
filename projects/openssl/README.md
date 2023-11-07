In this project we build OpenSSL, which we use only as a dependency for Tor.

# Caveats

- we have to force `lib` as a library directory for 64-bit platforms.
  The default would be `lib64`, but Tor cannot find it when using autoconf (see
  [tor#40807](https://gitlab.torproject.org/tpo/core/tor/-/issues/40807)).
- for macOS, we need to create a generic link `triplet-cc` to `clang`
- for Windows, we need to set `CC=cc`, otherwise OpenSSL defaults to `gcc`.
  This works because we create a generic `arch-w64-mingw32-cc` link in
  `mingw-w64-clang`
