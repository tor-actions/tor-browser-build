In this project we build `newfs_hfs`, which is the tool we use to create the HFS
volume to then embed into macOS installers.

We used to use ISO images, but they don't allow a custom volume icon, so we
moved to HFS.

The source tree can build also other tools, but we don't use them, so we don't
even build them.

# Caveats

## Linux port

This tool was written by Apple and released under an open source license, but
like other macOS tools, the official source code is macOS-specific.
So, we use a Linux port (that can be built only with Clang).
We use the same version as Mozilla (it can be checked in
`taskcluster/ci/fetch/toolchains.yml` on Firefox's source tree).

## Reproducibility patches

We have to apply a couple of patches to make sure the output is reproducible:

- we fix the UUID of the new volume (we set it to the volume name, and we fill
  it with zeros, if needed)
- the creation time is set in local time, even though we normalize the timezone
  of the containers to be UTC
