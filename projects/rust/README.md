In this project we build the Rust compiler.

# Dependency on the pre-built binaries

Bootstrapping Rust would be extremely time consuming: the Rust project doesn't
give any guarantee about compatibility with older versions.
You might need the previous version or even the latest beta.

There are some efforts to build a Rust bootstrapper such as
[mrustc](https://github.com/thepowersgang/mrustc), but it can build up to rustc
1.54.0.
This means we'd have to go through at least another dozen of versions to arrive
to the version we need.

So, for this reason, we download the official Rust binaries and then use them to
build rustc with our configuration.

We do not follow Mozilla's steps, as they do a custom build to run sanitizers.

# Clang as a compiler

Rust builds with
[Clang in their CI](https://github.com/rust-lang/rust/blob/master/src/ci/docker/host-x86_64/dist-x86_64-linux/Dockerfile),
so we also use Clang as our C compiler.

# External LLVM

By default, Rust would build LLVM, but it takes a long time and we already
build it in the `clang` project.

So, we tell Rust to use our existing LLVM tools.

This isn't a tested configuration, so it didn't work with Rust 1.69.
As a result, we had to backport the patch from Rust 1.70, but we'll be able to
remove it at the next update.

# Jemalloc

Rust also explicitly enables jemalloc in their CI.
When we omitted the same configuration,
[we hit a compiler bug](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40591)
when building Firefox (102, with Rust 1.60.0 on Debian Jessie), so we also
started enabling it.
