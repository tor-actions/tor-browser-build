This is the project to build Firefox for desktop.

# Steps

The build of this project happens in a few steps.
Here is an outline.

## Toolchain preparation

First, we prepare the toolchain.
This step is mostly platform-specific.

In addition to extracting the various artifacts compiled by other project, we
define a series of environment variables.

We also do some preparation to enable WASM as a target in clang, to enable WASI
sandboxing.
See also the `wasi-sysroot` project.

## Localization preparation

There are two ways to distribute a localized version of Firefox: include the
localization files at build time, or ship the browser with a language pack.

Language packs don't work well for us, because they are expected to contain all
the Fluent files. And we can't take existing language packs and add our new
files because language packs are addons and they need to be signed by Mozilla.

Legacy formats aren't affected by this problem, but adding them during the build
seems cleaner than injecting them after it.

Firefox doesn't version language files. Instead, each language has a Mercurial
repository in [l10n-central](https://hg.mozilla.org/l10n-central/), and it
expects to find them cloned in `$HOME/.mozbuild/l10n-central`.
The commit hashes that should be used with a certain Firefox version are in
`browser/locales/l10n-changesets.json`.
Luckily for us, the build system doesn't try to access Mercurial information,
therefore we can just place the string files.

Still, getting them with `tor-browser-build` isn't trivial, and there's some
magic involving a Perl script happening in `firefox-l10n`.

Testbuilds aren't localized by default, as it can save up to 10 minutes.
We used to save much more time when we didn't have multi-locale builds with this
setting.

References:
- [tor-browser#17400](https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/17400)
- [tor-browser#40924](https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/40924)

## Firefox configuration

We use `mozconfig`s from `tor-browser.git`, however we need to customize them to
include the paths to our toolchain.

Also, we set a few other settings, that depend on the build we're running
(update channel, branding, source commit hash to display in `about:buildconfig`,
etc...).

## Build

The build is the easiest part of the script 😄️. We just run the usual
`./mach build`.

Shall the build fail, you should search for `Error 1` in the logs.

## Collecting the files

After `./mach build`, we don't run `./mach package`, instead we run
`./mach build stage-package`.

The reason is that we need to do some further customization, and we create the
final packages in the `browser` project.

With localized builds, we also have to run a step to actually include the string
files, so we call `./mach package-multi-locale`.
By default, this would call `./mach package`, and it would not work in our
environment. So, we removed it with a patch in `tor-browser.git`.

For Linux and Windows we also collect debug symbols and ship them, but this
doesn't rely on specific Firefox commands.

## MAR tools

Firefox uses a custom MAR (Mozilla ARchive) format for updates.
In this project, we also build the utilities to work with them.

Some utilities (`mar` and `mbsdiff`) always target Linux. The rest targets the
same platform for which we're building Firefox.
