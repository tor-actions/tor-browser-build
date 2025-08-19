This projects is for the [Go](https://go.dev/) compiler.
We use it to build the various pluggable transports.

# Caveats

- The Go compiler is written in Go, so it needs another Go compiler to be built.
  We have another project (`go-bootstrap`) to provide it, and we make all
  targets use the `linux-x86_64` bootstrapper, since we don't need to
  cross-compile anything with it.
- We create a compiler wrapper to include our custom arguments on macOS and on
  Windows because the `make.bash` script seems to lose our arguments.
