Mozilla uses the python-zstandard module for various tasks in their CI, but
they do not vendor it in Firefox's source tree.

Since we build our own Python on Linux, we also need to build this module.
