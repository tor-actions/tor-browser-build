This is the [Nullsoft Scriptable Install System](https://nsis.sourceforge.io/),
which we use to build our Windows installers.

# Caveats

## 64-bit installers

We build 64-bit installers for x86_64, but it isn't officially supported.
The system plugin (that involves an assembly module) might be the reason, but we
don't use it.

For this reason we also have to patch the source code on the fly (we do it with
`sed`) when building it.

References:

- [tor-browser#23561](https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/23561)
- [nsis#1294](https://sourceforge.net/p/nsis/bugs/1294/)

## GCC dependency

NSIS is one of the two only projects that requires a GCC toolchain, rather than
our usual LLVM one.

## Problems with mandatory ASLR

Recent versions of binutils add an empty relocation section by default, which
causes NSIS installers not to work on systems where mandatory ASLR is turned on.

The root cause is that NSIS installers pretend to support ASLR to pass a
compatibility check with Windows Server 2012 (according to NSIS forum), but they
actually don't.

We solved by adding `-Wl,--disable-reloc-section` with a patch, but eventually
this fix should be applied also upstream.

References:

- [tor-browser-build#40822](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40822)
- [nsis#1283](https://sourceforge.net/p/nsis/bugs/1283/), where we found the
  workaround
- The
  [NSIS forum thread](https://web.archive.org/web/20150920123232/forums.winamp.com/showthread.php?t=344755)
  in which they mention the `IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE` flag for
  compatibility.
- [tor-browser-build#40900](https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/issues/40900)
