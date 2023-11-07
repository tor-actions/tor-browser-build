The [GNU Compiler Collection](https://gcc.gnu.org/), our default compiler for
Linux.

We build Linux binaries on an old version of Debian to maximize the binary
compatibility.
However, the version shipped by Debian is often too old to build some projects
(e.g., Clang).
So, we bootstrap a newer version.

We also build a newer version of libstdc++ to match Firefox's requirements.
Then we ship it and enable it if we detect that a host system uses an older
version.
