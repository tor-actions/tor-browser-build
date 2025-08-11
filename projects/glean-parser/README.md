[Glean](https://docs.telemetry.mozilla.org/concepts/glean/glean.html) is Mozilla's
telemetry framework. Projects that use Glean define metrics in .yaml files, which
are then parsed by a python tool called `glean_parser` into whatever language the
project is using.

Mozilla supports offline builds, as long as you provide the wheels for `glean_parser`
and its dependencies.

Downloading wheels in a reproducible way isn't easy because locking dependencies is
optional in Python. Some Python package managers make it easy, but they don't offer
a way to just downloads the wheels for offline environments. So, our current solution
is to download the wheels once, and then package them in one of our servers, rather
than having users download the various wheel from PyPI or another mirror.

This project's goal is to unify the place where we define the URLs and hashes of
these archives.
