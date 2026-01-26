Mozilla switched from JSMin (which produced invalid JS under some circumstances)
with to terser in
[Bug 1967968](https://bugzilla.mozilla.org/show_bug.cgi?id=1967968).

However, they did not version it.
Instead, they create an archive in their CI starting from a `package-lock.json`.

This project is the replacement for that archive.

When updating Firefox, remember to update this project too, if needed.
