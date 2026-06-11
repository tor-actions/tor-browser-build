This is a script to package the
[Tor Browser Manual](https://tb-manual.torproject.org/) and make it available
in the browser offline.

Most of the work is done by the GitLab CI, as we had several troubles when
trying to setup an automated lektor build (e.g., we needed some specific Python
versions, localization was missing in several pages, etc...).

So, since the manual doesn't contain binary executables, we decided not to build
it, but to mirror the latest result of the CI to make sure a build stays
reproducible (otherwise, CI artifacts would be deleted after a week).

The download of the latest CI artifacts can be done by the script
`tools/update_manual.py`.

However, the CI artifacts include a lot of files used by other Tor sites
but not from the manual, so they need to be deleted, and some of the
files need to be adapted for offline use. This is done by the script
`package_marble_build_artifacts.py` (which has tests in
`test_package_marble_build_artifacts.py`).
