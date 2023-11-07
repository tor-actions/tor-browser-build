This project is used to create the various container images on which the various
projects will run their build scripts.

# Image customization

The base image is created with `mmdebstrap` in `mmdebstrap-image`.
Then, the list of packages that will be installed can be customized with the
following variables:

- `var/arch_deps`: a list of additional packages that will be installed in
  addition to the ones in other lists. This is the list you should try to
  customize as a first step (it's empty by default).
- `var/deps`: the default list of dependencies, if you override it, all the
  default packages will not be installed.
  Use case: you need a series of packages for all platforms, and then minimal
  platform-specific variations, that can be set in `var/arch_deps`
- `var/essential_deps`: a list of basic dependencies that you might risk to add
  if you customize also `var/deps`. Projects should not override this variable,
  it should be defined only in `rbm.conf`

## Avoid, when possible

Even though container images aren't very big (they range between 150MB and
700MB), they will easily sum up, and together they can be one of the biggest
directory in `out`.

So, sometimes it might be better to add a package to the shared list, even
though this will trigger a rebuild of all the projects.
