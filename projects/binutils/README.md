The [GNU Binutils](https://www.gnu.org/software/binutils/) binary tools.

# Caveats

- We pass `MAKEINFO=true` as a `make` option to avoid creating documentation.
  This hack was needed on Debian Jessie because its `makeinfo` version was too
  old, but we do not need the documentation, so we decided to leave it in place.
