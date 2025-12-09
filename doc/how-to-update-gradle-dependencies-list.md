# Gradle Dependencies

## TL; DR

1. Open `projects/<project name>/config`.
2. Look for `# generate_gradle_dependencies_list: 1` and uncomment it.
3. Run `rbm/rbm build <project name> --target nightly --target torbrowser-android-<arch>`.
   For GeckoView, make sure to run a single-arch build to catch all dependencies
   at once.
   Testbuilds (i.e., `make torbrowser-testbuild-android-<arch>`) are single-arch
   by default, but you can also set `var/android_single_arch`.
4. Find the corresponding output: `ls -lt out/<project name> | head`.
5. Extract it.
6. Move the `gradle-dependencies-list.txt` you just extracted to
   `projects/<project name>/`. 

Theoretically, it should be also possible to set
`generate_gradle_dependencies_list: 1` in `rbm.local.conf`, run a full build and
update all dependencies at once.

## Rationale

Many of our Android projects use Gradle to build, which also handles
dependencies.

For reproducibility purposes, we need to stabilize them, so we version a list of
dependencies that are known for working in a file called
`gradle-dependencies-list.txt`.

This file has a simple format:

```
# Lines starting with '#' are comments
<sha265> | <URL>
```

In addition to guaranteeing reproducibility, this makes sure we do not get
poisoned dependencies in subsequent builds.

## Creating and/or updating the list

Gradle does not have official tooling to create such lists.

Instead, we pass `--info` to make sure Gradle logs information about downloads.
Therefore, these logs need to be captured to a file. Most commonly, Gradle is
invoked directly and in that case appending something like
`2>&1 | tee -a gradle-output.log` to the command line is enough.

After that, we parse the logs with the `projects/common/gen-gradle-deps-file.py`
script:

```shell
gen-gradle-deps-file.py gradle-output.log
```

This generates a new `gradle-dependencies-list.txt`.

This procedure can be run outside a tor-browser-build container, but for best compatibility,
it should run inside it.

Most of our Android projects have been equipped with a flag
(`var/generate_gradle_dependencies_list`) to do this automatically.

Therefore, it is possible to just enable this flag, and grab an updated file
from the output artifact.

New Android projects should be setup to do this.

Dependencies are keyed and cached. The key is a checksum of the
gradle-dependencies-list.txt file.

## Consuming the list

`projects/common/fetch-gradle-dependencies` is the consumer of the list.

It ignores the hash of the `.pom` files, as they might change, but it checks the
hashes of all the other artifacts.

You can wire it in your project with code that looks like this:

```yaml
- filename: gradle-dependencies-list.txt
  name: gradle-dependencies-list
- filename: 'gradle-dependencies-[% c("var/gradle_dependencies_version") %]'
  name: gradle-dependencies
  exec: '[% INCLUDE "fetch-gradle-dependencies" %]'
  enable: '[% !c("var/generate_gradle_dependencies_list") %]'
```

Then, you will have to patch your project to look for offline dependencies, too.
But this is project-specific.

Generally speaking, you will have to add a `mavenLocal()` entry to the
`repositories` section in some `build.gradle` file.
