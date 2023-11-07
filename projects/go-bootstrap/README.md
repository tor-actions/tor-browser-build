Go 1.4 was the last version written in C.
All the later versions need a Go compiler, that we provide with this project.

Also, starting from Go 1.20.x, Go introduced a new policy: Go 1.y.z needs at
least Go 1.(y - 3) to build. E.g., Go 1.19 can build Go 1.20, 1.21 and 1.22, but
no Go 1.23, which will need Go 1.20 or later.

So, right now we build Go 1.4 with Debian's GCC, then we use it to build Go
1.19.9, but at a certain point we will have to add another Go compiler.

Other alternatives are:
- use Debian's Go compiler (but we use a very old version of Debian for wider
  binary compatibility, so it's likely not to ship a recent enough compiler for
  bootstrapping purposes)
- use the [official binaries](https://go.dev/dl/) to bootstrap, like we do for
  Rust
