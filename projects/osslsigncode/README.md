[osslsigncode](https://github.com/mtrojnar/osslsigncode) is a tool that
implements Authenticode signing and timestamping with OpenSSL, to avoid using
Microsoft's `signtool.exe` and to be able to sign Windows executables from
Linux.

This project isn't built during normal builds, but only by signers.
