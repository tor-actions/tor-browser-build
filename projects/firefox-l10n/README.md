This package fetches the various language file from l10n-central, which is a
collection of Mercurial repositories with language files (one repository for
each language).

We need to provide Fluent files in `omni.ja` instead of using language packs
because we can't add new Fluent files when we use them.

Firefox includes a list of commit hashes to use with each language in
`browser/locales/l10n-changesets.json`.
This project includes a Perl script to parse it, and create an archive with all
the language files to pass to the Firefox project.
