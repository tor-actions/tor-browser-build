This project is configured as `var/compiler` for Android.

It contains a few versions of the Android SDK, build tools and the NDK.

It defines several environment variables that various build systems look for,
such as `ANDROID_HOME`.
Optionally, it also prepares gradle.

The output artifact includes only one version of the NDK, because of its huge
size, but the setup commands can use a custom version of the NDK, since some
projects need different versions (e.g., GeckoView and Application Services).

# Known issues

Not all the included versions might be needed to build our projects.
So, this project could use a cleanup.
