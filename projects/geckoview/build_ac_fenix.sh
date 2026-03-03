[% IF c('var/has_l10n') -%]
  echo "Injecting the Firefox's localization to GV $(date)"
  # No quotes on purpose, to pass each locale as an additional argument.
  ./mach package-multi-locale --locales en-US $supported_locales
[% END -%]

objdir=$(cd obj-* && pwd)

echo "Building Android Components $(date)"
pushd mobile/android/android-components
gradle $GRADLE_FLAGS assembleGecko -x lint [% IF c('var/online_build') %]2>&1 | tee -a $gradle_logs[% END %]
popd

# The build might fail with "file exists" otherwise.
rm -rf $GRADLE_HOME/glean/pythonenv

echo "Building Fenix $(date)"
pushd mobile/android/fenix

# Use the Android Components we have just built
echo autoPublish.android-components.dir=../android-components > local.properties

[% IF c('var/has_l10n') -%]
  tar -C $distdir -xf $rootdir/[% c('input_files_by_name/translation-fenix') %]
  # Add our localized strings
  supported_locales="[% tmpl(c('var/locales_mobile').join(' ')) %]"
  for lang in $supported_locales; do
    cp "$distdir/translation-fenix/$lang/torbrowser_strings.xml" "app/src/main/res/values-$lang/"
  done
[% END -%]

# Bug 40485: Inject deterministic build date into Glean.
echo 'ext.gleanBuildDate = "0"' >> app/build.gradle

variant='[% c("var/variant") %]'
version_name="[% c('var/torbrowser_version') %] ([% c('var/geckoview_version') %])"

echo "Building $variant Fenix APK"
gradle $GRADLE_FLAGS -PversionName="$version_name" "assemble$variant" [% IF c('var/online_build') %]2>&1 | tee -a $gradle_logs[% END %]

[% IF !c('var/generate_gradle_dependencies_list') -%]
  echo "Build finished, copying the APK(s) to the destination directory $(date)"
  mkdir -p $outdir/[% project %]
  mv $objdir/gradle/build/mobile/android/fenix/app/outputs/apk/$variant/*.apk $outdir/[% project %]
[% END -%]

echo "Building non optimized $variant Fenix APK for testing"
gradle $GRADLE_FLAGS -PversionName="$version_name" -PdisableOptimization "assemble$variant"

echo "Building Fenix instrumentation tests"
gradle $GRADLE_FLAGS -PversionName="$version_name" -PtestBuildType="$variant" -PdisableOptimization assembleAndroidTest [% IF c('var/online_build') %]2>&1 | tee -a $gradle_logs[% END %]

[% IF c('var/online_build') -%]
  $rootdir/gen-gradle-deps-file.py $gradle_logs
  cp gradle-dependencies-list.txt [% dest_dir _ '/' _ c('filename') %]
  [% IF c('var/generate_gradle_dependencies_list'); RETURN; END -%]
[% END -%]

echo "Test build finished, copying the APKs to the destination directory $(date)"

mkdir -p $outdir/[% project %]/tests
mv $objdir/gradle/build/mobile/android/fenix/app/outputs/apk/$variant/*.apk $outdir/[% project %]/tests
mv $objdir/gradle/build/mobile/android/fenix/app/outputs/apk/androidTest/$variant/*.apk $outdir/[% project %]/tests

popd
