This is the Lyrebird pluggable transport.

# Vendored dependencies

Lyrebird is written in Go, and we version the expected hash of the vendored
dependencies. Please refer to `doc/how-to-update-go-dependencies.txt` for
further information on how we manage dependencies of Go projects.

# Nightly builds

Tor Browser Nightly builds use the `main` branch from the git repository.

Dependencies are expected to change more frequently there, so we disabled the
hash check on the dependencies archive.
This does not apply to the release and alpha channels.
