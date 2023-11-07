This is the project we use to build the tor daemon.

We consume it in `tor-expert-bundle`, where we create an archive with `tor` and
all the pluggable transport, both for further consumption by other projects and
also for release.

# Dependencies

## OpenSSL

We build our version of OpenSSL (from the LTS channel) and ship it to all
platforms.

Linux is the only platform in which we perform dynamic linking of OpenSSL.
In all the other platforms we do static linking.

## Libevent

Similar considerations apply to Libevent, with the only difference that Libevent
is dynamically linked both on Linux and on macOS, and statically on Windows and
Android.

## zlib

We build and statically link zlib only on Android and on Windows.

For Linux, we add the zlib headers to the container image and load the library
provided by the OS at runtime.

For macOS, the SDK includes zlib already, and we load the library provided by
the OS at runtime.

## Zstandard

We enable zstd only on Android.
We plan to do it also on desktop platforms, see
[tor-browser-build#22341](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/22341).

## Other Linux libraries

For Linux we also include here libstdc++ (and the sanitizers, if enabled), even
though they aren't needed by tor.

Also, on we provide debug symbols, but only for Linux, and only in
`tor-expert-bundle`.
