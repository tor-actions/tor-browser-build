[Glean](https://docs.telemetry.mozilla.org/concepts/glean/glean.html) is
Mozilla's telemetry framework.
Mozilla provides SDKs for various programming languages.
In this project, we deal with the Python one, needed to build Application
Services and Firefox for Android.

Mozilla supports offline builds, as long as you provide the
[wheels](https://peps.python.org/pep-0427/) for `glean_parser` and its
dependencies.

Downloading wheels in a reproducible way isn't easy because locking dependencies
is optional in Python.
Some Python package managers make it easy, but they don't offer a way to just
downloads the wheels for offline environments.
So, our current solution is to download the wheels once, and then package them
in one of our servers, rather than having users download the various wheel from
PyPI or another mirror.

This project's goal is to unify the place where we define the URLs and hashes of
these archives.
