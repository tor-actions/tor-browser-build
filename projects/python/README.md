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
