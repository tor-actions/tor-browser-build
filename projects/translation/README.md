In this project we fetch the localization strings form our translation branches.

We manage the various branches as different steps, even though they share the
same (quite trivial) build script.

# Getting updated hashes

One of the steps to do when preparing a release is updating the commit hashes
of the translation branches.

We have two make targets to do it:

```shell
make list_translation_updates-alpha
make list_translation_updates-release
```

They assume you already ran a build, and so you already have a `translation.git`
clone in `git_clones`.

We fix the source hashes for reproducibility purposes, even though translations
do not have actually releases.

On the other hand, nightly builds use branch names, so they always have the
latest translations, which can help translators.
