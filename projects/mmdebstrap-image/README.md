In this project we use `mmdebstrap` to create basic images for our containers.

The images created in this way will not contain any additional packages.
Further customization happens in `container-image`, instead.

For the image creation we use Ubuntu because Debian didn't ship system images
when this project was set up.

# `minimal_apt_version`

`minimal_apt_version` is used in case an APT security bug is found to make sure
we're not installing any packages using a vulnerable version.

If the APT version of a suite didn't get a security update from its release, the
APT version in the repositories when we start using that suite can be used,
instead.

# Debian suites

## Linux x86_64

When targeting Linux, we use an old version to link an old enough glibc,
possibly the oldest our toolchain supports.

Matching the version used by Mozilla seems to work well.

Notice that for libstdc++ we ship the one we build, and check if we need to put
it in `LD_LIBRARY_PATH` before running Firefox (see `abicheck.cc` in `firefox`).

Using the `--sysroot` option of the compiler (or equivalent ones) might work as
well, but this solution seems to be easier.

References:

- [tor-browser#29158](https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/29158)
- [tor-browser-build#41016](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/41016)

## Other platforms

For other platforms (including Linux cross-compilation) we don't care of ABI
compatibility.

We can just use the latest Debian stable, unless there are specific reasons to
delay the change (e.g., some packages we were using have been removed).
