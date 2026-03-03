[% pc(c('var/compiler'), 'var/setup', {
  compiler_tarfile => c('input_files_by_name/' _ c('var/compiler')),
}) %]
[% pc('android-sdk', 'var/setup', { sdk_tarfile => c("input_files_by_name/android-sdk") }) %]
[% pc('gradle', 'var/setup', { gradle_tarfile => c("input_files_by_name/gradle") }) %]
distdir=/var/tmp/dist
builddir=/var/tmp/build
outdir="[%  dest_dir _ '/' _ c('filename') -%]"
mkdir -p $builddir $distdir [% IF !c("var/generate_gradle_dependencies_list") %]$outdir[% END %]

tar -C $distdir -xf [% c('input_files_by_name/node') %]
export PATH="/var/tmp/dist/node/bin:$PATH"

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

[% IF c("var/tor-browser") -%]
  # Normalize this path, as it will end up in buildconfig.html.
  export TOR_EXPERT_BUNDLE_AAR=/var/tmp/dist/tor-expert-bundle.aar
  mv $rootdir/[% c('input_files_by_name/tor-expert-bundle-aar') %]/tor-expert-bundle.aar $TOR_EXPERT_BUNDLE_AAR
[% END -%]

[% IF !c("var/firefox-browser") -%]
  tar -C /var/tmp/dist -xf [% c('input_files_by_name/application-services') %]
  export APPLICATION_SERVICES=/var/tmp/dist/application-services/maven
  export NIMBUS_FML=/var/tmp/dist/application-services/nimbus-fml
[% END -%]

[% INCLUDE 'fake-git' %]

tar -C /var/tmp/build -xf [% project %]-[% c('version') %].tar.[% c('compress_tar') %]

tar -C /var/tmp/build/[% project %]-*/tools/terser -xf [% c("input_files_by_name/terser") %]

[% c("var/set_MOZ_BUILD_DATE") %]

export JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64

[% IF !c('var/online_build') -%]
  gradle_repo=/var/tmp/dist/gradle-dependencies
  export GRADLE_MAVEN_REPOSITORIES="file://$gradle_repo","file://$gradle_repo/maven2"
  # Set the Maven local repository because Gradle ignores our overriding of $HOME.
  # It is only used for the local pubblication of single-arch AARs.
  export GRADLE_FLAGS="--no-daemon --offline -Dmaven.repo.local=$distdir/[% project %]"
  # Move the Gradle repo to a hard-coded location. The location is embedded in
  # the file chrome/toolkit/content/global/buildconfig.html so it needs to be
  # standardized for reproducibility.
  mv $rootdir/[% c('input_files_by_name/gradle-dependencies') %] $gradle_repo

  tar -xf [% c('input_files_by_name/glean') %]
  cp -rl $rootdir/glean/maven/* $gradle_repo

  cp -rl $gradle_repo/dl/android/maven2/* $gradle_repo || true
  cp -rl $gradle_repo/m2/* $gradle_repo || true
  cp -rl $gradle_repo/maven2/* $gradle_repo || true

  tar -xf [% c('input_files_by_name/glean-wheels') %]
  export GLEAN_PYTHON_WHEELS_DIR=$rootdir/glean-wheels
[% ELSE -%]
  gradle_logs=/var/tmp/build/gradle-logs.log
  export GRADLE_FLAGS="--no-daemon --info"
[% END -%]

# We unbreak mach, see: https://bugzilla.mozilla.org/show_bug.cgi?id=1656993.
export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=system
# Create .mozbuild to avoid interactive prompt in configure
mkdir "$HOME/.mozbuild"

# mach looks for bundletool and avd only in ~/.mozbuild. Maybe an upstream bug?
mv $rootdir/[% c("input_files_by_name/bundletool") %] $HOME/.mozbuild/bundletool.jar
mkdir $HOME/.mozbuild/android-device
touch $HOME/.mozbuild/android-device/avd
chmod +x $HOME/.mozbuild/android-device/avd

[% INCLUDE 'browser-localization' %]

cd $builddir/[% project %]-[% c("version") %]
cp $rootdir/mozconfig ./

# We need this to avoid a `java.lang.OutOfMemoryError: GC overhead limit exceeded`
sed -i -e 's/-Xmx7g/-Xmx32g/' gradle.properties \
  mobile/android/android-components/gradle.properties \
  mobile/android/fenix/gradle.properties

echo "Starting ./mach configure $(date)"
# We still need to specify --base-browser-version due to bug 34005.
./mach configure \
  [% IF !c("var/firefox-browser") %]--with-base-browser-version=[% c("var/torbrowser_version") %][% END %] \
  [% IF !c("var/firefox-browser") %]--with-branding=$branding_dir[% END %] \
  [% IF !c("var/rlbox") -%]--without-wasm-sandboxed-libraries[% END %]
