In this project we build the `hfsplus` and `dmg` utilities we use to build macOS
packages.

`hfsplus` is a tool to manipulate a HFS filesystem (add files, etc) without
mounting it.

`dmg` is a tool we use to convert the HFS volume into a DMG archive.

We use [Mozilla's fork](https://github.com/mozilla/libdmg-hfsplus) of the
original project.
The source tree includes more utilities, but we don't use them, so we don't
build them.
