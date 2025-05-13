TAPI stands for Text-based Application Programming Interface and it's a way
Apple uses to reduce the size of the macOS SDK.

We need this library as a dependency of `cctools`.

Just like `cctools`, we use the same version as Mozilla (which can be found in
Firefox's `taskcluster/kinds/fetch/toolchains.yml`) and from the same Linux port
they use.

Our build script is based on Firefox's
`taskcluster/scripts/misc/build-cctools-port.sh`.

# Caveats

Our script defines old values for `TAPI_REPOSITORY` and for `TAPI_VERSION`, but
Mozilla build script does the same.
