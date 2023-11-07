This is the [WASI SDK](https://github.com/WebAssembly/wasi-sdk), referred as
`wasi-sysroot` by Firefox build system.

Firefox uses it to sandbox certain libraries by compiling them to WASM first
(and configure them to use the WASI sandbox while doing so) before compiling
them to native code.

References:
- [WebAssembly and Back Again: Fine-Grained Sandboxing in Firefox 95](https://hacks.mozilla.org/2021/12/webassembly-and-back-again-fine-grained-sandboxing-in-firefox-95/)

# "Manual" git submodules

The WASI SDKs uses git submodules.
While RBM can manage them, one of the three submodules is LLVM, which is quite
big.
Moreover, we already have a project to share the LLVM source code
(`llvm-project`) and we do a few tricks do avoid building another Clang that
would be wasted after building the WASI SDK (well, we copied the trick from
Mozilla 😄️).

Still, the project has another two submodules, so we had to create a couple of
additional tor-browser-build projects to provide them: `wasi-config` and
`wasi-libc`.

If you need to update the version of the WASI SDK, please be sure to update also
the hashes of the submodules.

We stick to the same version used by Firefox, that can be found in the usual
`taskcluster/ci/fetch/toolchains.yml`.

# Mozilla's build script

Our build script is an adaptation of Firefox's
`taskcluster/scripts/misc/build-sysroot-wasi.sh`.
After ESR updates, we should check if that script was updated.

The main difference is that Mozilla builds `libclang_rt.builtins-wasm32.a` with
Clang, whereas we build it here and inject it only in the `firefox`/`geckoview`
projects.

# Different build ids, same outputs

Some of the considerations we did for Clang apply also to this project: we build
this project for each platform, but eventually they produce the same exact
result.

The problem is that they have different container images and/or container setup
steps, which causes the build id to be different.

In the future, we might use a common target, shall we create one.
