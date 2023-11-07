cctools are various tools used for native code development.
Apple releases them with an open source license, but they are not compatible
with Linux and other operating systems, therefore we build a
[port](https://github.com/tpoechtrager/cctools-port).

Firefox also builds this port, therefore we match the version you can find in
`taskcluster/ci/fetch/toolchains.yml` in Firefox's source tree.

# Caveats

We follow the same procedure as Mozilla.
You can find it in `taskcluster/scripts/misc/build-cctools-port.sh`.

So, we target x86_64, and then we symlink all the tools with an aarch64 prefix
and we create a `lipo` tool without any prefix.
