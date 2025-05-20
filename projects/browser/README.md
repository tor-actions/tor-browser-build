In this project we create the final packages/installers.

What we do varies from platform to platform.

# Desktop

On desktop, we take all the binaries we've built so far (`firefox`,
`tor-expert-bundle`) and the various additional files (extensions, the manual,
documentation, copyright files...).
We create the structure we want for the installation, and package it for
distribution.

If the updater is enabled, in addition to the platform-specific formats, we
create also `.mar`s (Mozilla ARchives).

The most complex platform is macOS: we also merge x86_64 and aarch64 binaries in
this project, with a procedure we adapted from Firefox.

Before having multi-lingual packages, we used to create the localized packages
during this step, and some of the complications this implied are still visible.

# Android

The Android script is much simpler.
Tor and pluggable transports are already packaged in `tor-android-service` and
`tor-onion-proxy-library`.
The only missing piece is NoScript, so we add it to the APK produced by
`geckoview`.

This APK is unsigned, so we sign with a private key we ship in
`android-qa.keystore`, so that the APK we ship can be installed for QA (Android
refuses to install unsigned APKs, unless they're the debuggable version).

Notice that we strip this signature from release and alpha APKs, and apply a new
one with another certificate that is enabled to publish on Google Play during
the signing process.
