With this project we build compiler-rt and LLVM's libunwind for Android.

They are needed only by GeckoView, as it's the only project that uses our custom
Clang as a compiler (all the other ones use Clang from the NDK or Debian's GCC
if the compiler is needed only for host tools).

So, we build them in a separate project from Clang, so that in the future we'll
be able to build Clang only once for Android, macOS and Windows.

We use the same flags (and tricks) as Mozilla. Basically, our build script is an
adaptation of Firefox's `taskcluster/scripts/misc/build-llvm-common.sh` to
tor-browser-build.
