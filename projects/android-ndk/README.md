This projects downloads and repacks the Android NDK, which we use as the
default compiler for Android.

We used to set the `android-toolchain` project as `var/compiler`, but most of
the projects only need the NDK, so any error in `android-toolchain` would
trigger unneeded rebuilds, making iteration times longer.

We keep the NDK version in sync with the version used by Mozilla.
