The [Ninja](https://ninja-build.org/) build system.
Some projects explicitly require it, for some other we use it with CMake.

We use the latest stable version.

# `python3` compatibility

Python 3 is needed to build ninja, however several files still use `python`
instead of `python3` in the shebang in the latest stable.

So, we backported the commit as a `.patch` file, but we will be able to remove
it in the future.
