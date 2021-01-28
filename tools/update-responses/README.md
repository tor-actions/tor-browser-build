Tor Browser Update Responses script
===================================

This directory contains a script to generate xml update responses and
incremental mar files for the Tor Browser updater.

See ticket [#12622](https://gitlab.torproject.org/legacy/trac/-/issues/12622)
for details.


Dependencies
------------

The following perl modules need to be installed to run the script:
  FindBin YAML::XS File::Slurp Digest::SHA XML::Writer File::Temp
  IO::CaptureOutput Parallel::ForkManager XML::LibXML LWP JSON

On Debian / Ubuntu you can install them with:

```
  # apt-get install libfindbin-libs-perl libyaml-libyaml-perl \
                    libfile-slurp-perl libdigest-sha-perl libxml-writer-perl \
                    libio-captureoutput-perl libparallel-forkmanager-perl \
                    libxml-libxml-perl libwww-perl libjson-perl
```

On Red Hat / Fedora you can install them with:

```
  # for module in FindBin YAML::XS File::Slurp Digest::SHA XML::Writer \
                  File::Temp IO::CaptureOutput Parallel::ForkManager \
                  XML::LibXML LWP JSON
    do yum install "perl($module)"; done
```


Running the script
------------------

We usually don't run the script directly. Instead we run one of the
following make commands:

 - make update_responses-alpha or make update_responses-release to
   generate update responses files for an alpha or stable release.

 - make incrementals-alpha or make incrementals-release to generate
   incremental mar files for an alpha or stable release.

 - make dmg2mar-alpha or make dmg2mar-release to generate updated mar
   files for the macOS bundles, from their dmg files, for an alpha or
   stable release.

In addition to running the script, those make commands will generate
the configuration file for the script, in tools/update-responses/config.yml,
from a template in projects/release/update_responses_config.yml.


URL Format
----------

The generated update responses files expect the following URL format:
  https://something/$channel/$build_target/$tb_version/$lang?force=1

'build_target' is the OS for which the browser was built. The
correspondance between the build target and the OS name that we use in
archive files is defined in the config.yml file.

'tb_version' is the Tor Browser version.

'lang' is the locale.

