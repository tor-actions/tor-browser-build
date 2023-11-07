[Libevent](https://libevent.org/) is a tor dependency.

We build it as a shared library on Linux and macOS, and as a static library on
Windows and Android.

# Caveats

On macOS we need to use faketime for reproducibility purposes.
