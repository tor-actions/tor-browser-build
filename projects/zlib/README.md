In this project we build zlib, which we need as a Tor dependency (and also as an
NSIS dependency, on Windows).

Firefox also uses zlib, but it handles it on its own.

We do not use this project on Linux and macOS, but we rely on the system
library instead (we add the headers to the container for Linux, when necessary,
and macOS provides libz in its SDK).
