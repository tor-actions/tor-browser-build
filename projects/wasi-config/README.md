These are the GNU
[config.guess and config.sub](https://savannah.gnu.org/projects/config/)
scripts.

They are included by the `wasi-sysroot` project as a git submodule.
While RBM could handle submodules on its own,we prefer not to because LLVM is
also one of the submodules of `wasi-sysroot`.

`wasi-sysroot`, `wasi-config` and `wasi-libc` should always  be updated
together.
