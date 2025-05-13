[cbindgen](https://github.com/mozilla/cbindgen) creates C/C++11 headers for Rust
libraries which expose a public C API.

It is needed to build Firefox and GeckoView, therefore we adhere to the version
that is known to work with their version.
It can be found in Firefox's source tree by cross-referencing
`taskcluster/kinds/toolchain/cbindgen.yml` and
`taskcluster/kinds/fetch/toolchains.yml`.

# Vendored dependencies

cbindgen has external dependencies which it manages through cargo.
It also provides a `Cargo.lock` to ensure reproducibility.

We create the dependency archive in a separate step (`cargo_vendor`),
implemented in `rbm.conf`.

When updating the project version, you should update also the expected hash of
the dependency archive.
You can create one with the `cargo_vendor-cbindgen` make target.
