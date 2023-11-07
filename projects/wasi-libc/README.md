`wasi-libc` is a libc for WebAssembly programs built on top of WASI system
calls.

It's included by the `wasi-sysroot` project as a git submodule.
While RBM could handle submodules on its own,we prefer not to because LLVM is
also one of the submodules of `wasi-sysroot`.

`wasi-sysroot`, `wasi-config` and `wasi-libc` should always  be updated
together.
