The build systems of some projects we build need a recent version of Python 3,
and the one we have in the old version of Debian we use isn't recent enough.

So, for Linux we build this project and conditionally require it in some
projects:

```yaml
  - project: python
    name: python
    enable: '[% c("var/linux") %]'
```

For some projects, the version Debian provides would be okay, but we normally
don't install `python3` as a standard package (`var/deps`) for Linux, so we end
up using this project also in that case, rather than creating a new container
image.

`browser` is a notable exception: we redefine `var/deps` for all platforms and
already add `python3` there.

## OpenSSL

Some Python module complain about the OpenSSL version of the container being
too old. Therefore, we also build OpenSSL in this project, and other projects
needing it must add `/var/tmp/dist/python/lib` to `LD_LIBRARY_PATH`.

We do it here instead of using the `openssl` project because we do not want to
rebuild a big part of the toolchain for each OpenSSL update (the module would
be used mostly for HTTP requests, which will not go through in our builds,
since they happen offline).

When updating to a newever version of Debian for Linux containers, we might
stop building OpenSSL and go back to using the system library.
