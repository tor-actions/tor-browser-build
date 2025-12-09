# ❌ Revert Patchset
<!--
This is an issue for tracking reverting a patch-set (e.g. Time-gated features
which are no longer needed after the expiration date)

Please ensure the title has the following format:

- Revert tor-browser-build#12345: Title of original issue
-->

## Bookkeeping

### Time Window
<!--
When should this patchset be reverted?
-->

- **Revert-After Date**
  - Date:

### Issue(s)
<!-- issue associated with the original patchset -->
- tor-browser#xxxxx
- mullvad-browser#xyz
- tor-browser-build#xxxxx

### Merge Request(s)
<!-- merge-request associated with the original patchset -->
- tor-browser-build!xxxx

### Target Channels
<!-- Which channel has the commits we need to revert? -->
- [ ] main
- [ ] maint-15.0

## Notes

<!-- whatever additional info, context, etc that would be helpful for reverting -->


<!-- Do not edit beneath this line <3 -->

---

/label ~"Apps::Product::TorBrowserBuild"
/label ~"Apps::Type::Chore"
