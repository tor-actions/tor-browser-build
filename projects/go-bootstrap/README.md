This project downloads the official Go binaries to use them for bootstrapping
purposes.

We used to start with Go 1.4 (the last version written in C) and build all the
versions needed to then build the most recent Go toolchain.

However, starting with Go 1.21,
[the official binaries are reproducible](https://go.dev/blog/rebuild).

So, we checked that the Go 1.23.6 binaries we produced with our old procedure
at 80f16f97e7c2973e9aa4458606c9afd2c63c2d60 matched the official binaries.

## How to update

1. In `projects/go/config`, update version to the version we want to be the new
   go-bootstrap version
2. Build `go` with
   `./rbm/rbm build --target torbrowser-linux-x86_64 --target alpha go` and
   compare the result with the official build
3. If it is matching or if we can explain the differences, update the
   `go-bootstrap` version of the bin that we download.
4. Build the same version of go again with the command from above and check the
   two archives have the same exact hash.
