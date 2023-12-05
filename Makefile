rbm=./rbm/rbm

all: torbrowser-release

#######################
# Tor Browser Targets #
#######################

torbrowser-release: submodule-update
	$(rbm) build release --target release --target browser-all --target torbrowser

torbrowser-release-android: submodule-update
	$(rbm) build release --target release --target browser-all-android --target torbrowser

torbrowser-release-android-armv7: submodule-update
	$(rbm) build release --target release --target browser-android-armv7 --target torbrowser

torbrowser-release-android-x86: submodule-update
	$(rbm) build release --target release --target browser-android-x86 --target torbrowser

torbrowser-release-android-x86_64: submodule-update
	$(rbm) build release --target release --target browser-android-x86_64 --target torbrowser

torbrowser-release-android-aarch64: submodule-update
	$(rbm) build release --target release --target browser-android-aarch64 --target torbrowser

torbrowser-release-desktop: submodule-update
	$(rbm) build release --target release --target browser-all-desktop --target torbrowser

torbrowser-release-linux-x86_64: submodule-update
	$(rbm) build release --target release --target browser-linux-x86_64 --target torbrowser

torbrowser-release-linux-x86_64-asan: submodule-update
	$(rbm) build release --target release --target browser-linux-x86_64-asan --target torbrowser

torbrowser-release-linux-i686: submodule-update
	$(rbm) build release --target release --target browser-linux-i686 --target torbrowser

torbrowser-release-windows-i686: submodule-update
	$(rbm) build release --target release --target browser-windows-i686 --target torbrowser

torbrowser-release-windows-x86_64: submodule-update
	$(rbm) build release --target release --target browser-windows-x86_64 --target torbrowser

torbrowser-release-macos: submodule-update
	$(rbm) build release --target release --target browser-macos --target torbrowser

torbrowser-release-src: submodule-update
	$(rbm) build release --target release --target browser-src --target torbrowser

torbrowser-alpha: submodule-update
	$(rbm) build release --target alpha --target browser-all --target torbrowser

torbrowser-alpha-android: submodule-update
	$(rbm) build release --target alpha --target browser-all-android --target torbrowser

torbrowser-alpha-android-armv7: submodule-update
	$(rbm) build release --target alpha --target browser-android-armv7 --target torbrowser

torbrowser-alpha-android-x86: submodule-update
	$(rbm) build release --target alpha --target browser-android-x86 --target torbrowser

torbrowser-alpha-android-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-android-x86_64 --target torbrowser

torbrowser-alpha-android-aarch64: submodule-update
	$(rbm) build release --target alpha --target browser-android-aarch64 --target torbrowser

torbrowser-alpha-desktop: submodule-update
	$(rbm) build release --target alpha --target browser-all-desktop --target torbrowser

torbrowser-alpha-linux-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-linux-x86_64 --target torbrowser

torbrowser-alpha-linux-x86_64-asan: submodule-update
	$(rbm) build release --target alpha --target browser-linux-x86_64-asan --target torbrowser

torbrowser-alpha-linux-i686: submodule-update
	$(rbm) build release --target alpha --target browser-linux-i686 --target torbrowser

torbrowser-alpha-windows-i686: submodule-update
	$(rbm) build release --target alpha --target browser-windows-i686 --target torbrowser

torbrowser-alpha-windows-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-windows-x86_64 --target torbrowser

torbrowser-alpha-macos: submodule-update
	$(rbm) build release --target alpha --target browser-macos --target torbrowser

torbrowser-alpha-src: submodule-update
	$(rbm) build release --target alpha --target browser-src --target torbrowser

torbrowser-nightly: submodule-update
	$(rbm) build release --target nightly --target browser-all --target torbrowser

torbrowser-nightly-android: submodule-update
	$(rbm) build release --target nightly --target browser-all-android --target torbrowser

torbrowser-nightly-android-armv7: submodule-update
	$(rbm) build release --target nightly --target browser-android-armv7 --target torbrowser

torbrowser-nightly-android-x86: submodule-update
	$(rbm) build release --target nightly --target browser-android-x86 --target torbrowser

torbrowser-nightly-android-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-android-x86_64 --target torbrowser

torbrowser-nightly-android-aarch64: submodule-update
	$(rbm) build release --target nightly --target browser-android-aarch64 --target torbrowser

torbrowser-nightly-desktop: submodule-update
	$(rbm) build release --target nightly --target browser-all-desktop --target torbrowser

torbrowser-nightly-linux-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-linux-x86_64 --target torbrowser

torbrowser-nightly-linux-x86_64-asan: submodule-update
	$(rbm) build release --target nightly --target browser-linux-x86_64-asan --target torbrowser

torbrowser-nightly-linux-i686: submodule-update
	$(rbm) build release --target nightly --target browser-linux-i686 --target torbrowser

torbrowser-nightly-windows-i686: submodule-update
	$(rbm) build release --target nightly --target browser-windows-i686 --target torbrowser

torbrowser-nightly-windows-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-windows-x86_64 --target torbrowser

torbrowser-nightly-macos: submodule-update
	$(rbm) build release --target nightly --target browser-macos --target torbrowser

torbrowser-nightly-src: submodule-update
	$(rbm) build release --target nightly --target browser-src --target torbrowser

torbrowser-testbuild: submodule-update
	$(rbm) build release --target testbuild --target browser-all --target torbrowser

torbrowser-testbuild-android: submodule-update
	$(rbm) build release --target testbuild --target browser-all-android --target torbrowser

torbrowser-testbuild-android-armv7: submodule-update
	$(rbm) build release --target testbuild --target browser-android-armv7 --target torbrowser

torbrowser-testbuild-android-x86: submodule-update
	$(rbm) build release --target testbuild --target browser-android-x86 --target torbrowser

torbrowser-testbuild-android-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-android-x86_64 --target torbrowser

torbrowser-testbuild-android-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-android-aarch64 --target torbrowser

torbrowser-testbuild-desktop: submodule-update
	$(rbm) build release --target testbuild --target browser-all-desktop --target torbrowser

torbrowser-testbuild-linux-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-x86_64 --target torbrowser

torbrowser-testbuild-linux-x86_64-asan: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-x86_64-asan --target torbrowser

torbrowser-testbuild-linux-i686: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-i686 --target torbrowser

torbrowser-testbuild-windows-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-windows-x86_64 --target torbrowser

torbrowser-testbuild-windows-i686: submodule-update
	$(rbm) build release --target testbuild --target browser-windows-i686 --target torbrowser

torbrowser-testbuild-macos: submodule-update
	$(rbm) build release --target testbuild --target browser-macos --target torbrowser

torbrowser-testbuild-macos-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-macos-x86_64 --target torbrowser

torbrowser-testbuild-macos-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-macos-aarch64 --target torbrowser

torbrowser-testbuild-src: submodule-update
	$(rbm) build release --target testbuild --target browser-src-testbuild --target torbrowser

torbrowser-incrementals-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target create_unsigned_incrementals --target torbrowser
	tools/update-responses/download_missing_versions release
	tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release --target torbrowser

torbrowser-incrementals-release-unsigned: submodule-update
	$(rbm) build release --step update_responses_config --target release --target unsigned_releases_dir --target torbrowser
	$(rbm) build release --step link_old_mar_filenames --target release --target unsigned_releases_dir --target torbrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release --target torbrowser

torbrowser-incrementals-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target create_unsigned_incrementals --target torbrowser
	tools/update-responses/download_missing_versions alpha
	tools/update-responses/gen_incrementals alpha
	$(rbm) build release --step hash_incrementals --target alpha --target torbrowser

torbrowser-incrementals-alpha-unsigned: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target unsigned_releases_dir --target torbrowser
	$(rbm) build release --step link_old_mar_filenames --target alpha --target unsigned_releases_dir --target torbrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals alpha
	$(rbm) build release --step hash_incrementals --target alpha --target torbrowser

torbrowser-incrementals-nightly: submodule-update
	$(rbm) build release --step update_responses_config --target nightly --target torbrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals nightly
	$(rbm) build release --step hash_incrementals --target nightly --target torbrowser

torbrowser-update_responses-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target signed --target torbrowser
	$(rbm) build release --step create_update_responses_tar --target release --target signed --target torbrowser

torbrowser-update_responses-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target signed --target torbrowser
	$(rbm) build release --step create_update_responses_tar --target alpha --target signed --target torbrowser

torbrowser-dmg2mar-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target signed --target torbrowser
	$(rbm) build release --step dmg2mar --target release --target signed --target torbrowser
	tools/update-responses/download_missing_versions release
	CHECK_CODESIGNATURE_EXISTS=1 MAR_SKIP_EXISTING=1 tools/update-responses/gen_incrementals release

torbrowser-dmg2mar-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target signed --target torbrowser
	$(rbm) build release --step dmg2mar --target alpha --target signed --target torbrowser
	tools/update-responses/download_missing_versions alpha
	CHECK_CODESIGNATURE_EXISTS=1 MAR_SKIP_EXISTING=1 tools/update-responses/gen_incrementals alpha

torbrowser-compare-windows-signed-unsigned-release: submodule-update
	$(rbm) build release --step compare_windows_signed_unsigned_exe --target release --target signed --target torbrowser

torbrowser-compare-windows-signed-unsigned-alpha: submodule-update
	$(rbm) build release --step compare_windows_signed_unsigned_exe --target alpha --target signed --target torbrowser

torbrowser-compare-mar-signed-unsigned-release: submodule-update
	$(rbm) build release --step compare_mar_signed_unsigned --target release --target signed --target torbrowser

torbrowser-compare-mar-signed-unsigned-alpha: submodule-update
	$(rbm) build release --step compare_mar_signed_unsigned --target alpha --target signed --target torbrowser


########################
# Base Browser Targets #
########################

basebrowser-release: submodule-update
	$(rbm) build release --target release --target browser-all --target basebrowser

basebrowser-release-android: submodule-update
	$(rbm) build release --target release --target browser-all-android --target basebrowser

basebrowser-release-android-armv7: submodule-update
	$(rbm) build release --target release --target browser-android-armv7 --target basebrowser

basebrowser-release-android-x86: submodule-update
	$(rbm) build release --target release --target browser-android-x86 --target basebrowser

basebrowser-release-android-x86_64: submodule-update
	$(rbm) build release --target release --target browser-android-x86_64 --target basebrowser

basebrowser-release-android-aarch64: submodule-update
	$(rbm) build release --target release --target browser-android-aarch64 --target basebrowser

basebrowser-release-desktop: submodule-update
	$(rbm) build release --target release --target browser-all-desktop --target basebrowser

basebrowser-release-linux-x86_64: submodule-update
	$(rbm) build release --target release --target browser-linux-x86_64 --target basebrowser

basebrowser-release-linux-x86_64-asan: submodule-update
	$(rbm) build release --target release --target browser-linux-x86_64-asan --target basebrowser

basebrowser-release-linux-i686: submodule-update
	$(rbm) build release --target release --target browser-linux-i686 --target basebrowser

basebrowser-release-windows-i686: submodule-update
	$(rbm) build release --target release --target browser-windows-i686 --target basebrowser

basebrowser-release-windows-x86_64: submodule-update
	$(rbm) build release --target release --target browser-windows-x86_64 --target basebrowser

basebrowser-release-macos: submodule-update
	$(rbm) build release --target release --target browser-macos --target basebrowser

basebrowser-release-src: submodule-update
	$(rbm) build release --target release --target browser-src --target basebrowser

basebrowser-alpha: submodule-update
	$(rbm) build release --target alpha --target browser-all --target basebrowser

basebrowser-alpha-android: submodule-update
	$(rbm) build release --target alpha --target browser-all-android --target basebrowser

basebrowser-alpha-android-armv7: submodule-update
	$(rbm) build release --target alpha --target browser-android-armv7 --target basebrowser

basebrowser-alpha-android-x86: submodule-update
	$(rbm) build release --target alpha --target browser-android-x86 --target basebrowser

basebrowser-alpha-android-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-android-x86_64 --target basebrowser

basebrowser-alpha-android-aarch64: submodule-update
	$(rbm) build release --target alpha --target browser-android-aarch64 --target basebrowser

basebrowser-alpha-desktop: submodule-update
	$(rbm) build release --target alpha --target browser-all-desktop --target basebrowser

basebrowser-alpha-linux-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-linux-x86_64 --target basebrowser

basebrowser-alpha-linux-x86_64-asan: submodule-update
	$(rbm) build release --target alpha --target browser-linux-x86_64-asan --target basebrowser

basebrowser-alpha-linux-i686: submodule-update
	$(rbm) build release --target alpha --target browser-linux-i686 --target basebrowser

basebrowser-alpha-windows-i686: submodule-update
	$(rbm) build release --target alpha --target browser-windows-i686 --target basebrowser

basebrowser-alpha-windows-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-windows-x86_64 --target basebrowser

basebrowser-alpha-macos: submodule-update
	$(rbm) build release --target alpha --target browser-macos --target basebrowser

basebrowser-alpha-src: submodule-update
	$(rbm) build release --target alpha --target browser-src --target basebrowser

basebrowser-nightly: submodule-update
	$(rbm) build release --target nightly --target browser-all --target basebrowser

basebrowser-nightly-android: submodule-update
	$(rbm) build release --target nightly --target browser-all-android --target basebrowser

basebrowser-nightly-android-armv7: submodule-update
	$(rbm) build release --target nightly --target browser-android-armv7 --target basebrowser

basebrowser-nightly-android-x86: submodule-update
	$(rbm) build release --target nightly --target browser-android-x86 --target basebrowser

basebrowser-nightly-android-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-android-x86_64 --target basebrowser

basebrowser-nightly-android-aarch64: submodule-update
	$(rbm) build release --target nightly --target browser-android-aarch64 --target basebrowser

basebrowser-nightly-desktop: submodule-update
	$(rbm) build release --target nightly --target browser-all-desktop --target basebrowser

basebrowser-nightly-linux-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-linux-x86_64 --target basebrowser

basebrowser-nightly-linux-x86_64-asan: submodule-update
	$(rbm) build release --target nightly --target browser-linux-x86_64-asan --target basebrowser

basebrowser-nightly-linux-i686: submodule-update
	$(rbm) build release --target nightly --target browser-linux-i686 --target basebrowser

basebrowser-nightly-windows-i686: submodule-update
	$(rbm) build release --target nightly --target browser-windows-i686 --target basebrowser

basebrowser-nightly-windows-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-windows-x86_64 --target basebrowser

basebrowser-nightly-macos: submodule-update
	$(rbm) build release --target nightly --target browser-macos --target basebrowser

basebrowser-nightly-src: submodule-update
	$(rbm) build release --target nightly --target browser-src --target basebrowser

basebrowser-testbuild: submodule-update
	$(rbm) build release --target testbuild --target browser-all --target basebrowser

basebrowser-testbuild-android: submodule-update
	$(rbm) build release --target testbuild --target browser-all-android --target basebrowser

basebrowser-testbuild-android-armv7: submodule-update
	$(rbm) build release --target testbuild --target browser-android-armv7 --target basebrowser

basebrowser-testbuild-android-x86: submodule-update
	$(rbm) build release --target testbuild --target browser-android-x86 --target basebrowser

basebrowser-testbuild-android-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-android-x86_64 --target basebrowser

basebrowser-testbuild-android-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-android-aarch64 --target basebrowser

basebrowser-testbuild-desktop: submodule-update
	$(rbm) build release --target testbuild --target browser-all-desktop --target basebrowser

basebrowser-testbuild-linux-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-x86_64 --target basebrowser

basebrowser-testbuild-linux-x86_64-asan: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-x86_64-asan --target basebrowser

basebrowser-testbuild-linux-i686: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-i686 --target basebrowser

basebrowser-testbuild-windows-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-windows-x86_64 --target basebrowser

basebrowser-testbuild-windows-i686: submodule-update
	$(rbm) build release --target testbuild --target browser-windows-i686 --target basebrowser

basebrowser-testbuild-macos: submodule-update
	$(rbm) build release --target testbuild --target browser-macos --target basebrowser

basebrowser-testbuild-macos-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-macos-x86_64 --target basebrowser

basebrowser-testbuild-macos-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-macos-aarch64 --target basebrowser

basebrowser-testbuild-src: submodule-update
	$(rbm) build release --target testbuild --target browser-src-testbuild --target basebrowser

basebrowser-incrementals-nightly: submodule-update
	$(rbm) build release --step update_responses_config --target nightly --target basebrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals nightly
	$(rbm) build release --step hash_incrementals --target nightly --target basebrowser


###########################
# Mullvad Browser Targets #
###########################

mullvadbrowser-release: submodule-update
	$(rbm) build release --target release --target browser-all-desktop --target mullvadbrowser

mullvadbrowser-release-desktop: submodule-update
	$(rbm) build release --target release --target browser-all-desktop --target mullvadbrowser

mullvadbrowser-release-linux-x86_64: submodule-update
	$(rbm) build release --target release --target browser-linux-x86_64 --target mullvadbrowser

mullvadbrowser-release-linux-x86_64-asan: submodule-update
	$(rbm) build release --target release --target browser-linux-x86_64-asan --target mullvadbrowser

mullvadbrowser-release-windows-x86_64: submodule-update
	$(rbm) build release --target release --target browser-windows-x86_64 --target mullvadbrowser

mullvadbrowser-release-macos: submodule-update
	$(rbm) build release --target release --target browser-macos --target mullvadbrowser

mullvadbrowser-release-src: submodule-update
	$(rbm) build release --target release --target browser-src --target mullvadbrowser

mullvadbrowser-alpha: submodule-update
	$(rbm) build release --target alpha --target browser-all-desktop --target mullvadbrowser

mullvadbrowser-alpha-desktop: submodule-update
	$(rbm) build release --target alpha --target browser-all-desktop --target mullvadbrowser

mullvadbrowser-alpha-linux-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-linux-x86_64 --target mullvadbrowser

mullvadbrowser-alpha-linux-x86_64-asan: submodule-update
	$(rbm) build release --target alpha --target browser-linux-x86_64-asan --target mullvadbrowser

mullvadbrowser-alpha-windows-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-windows-x86_64 --target mullvadbrowser

mullvadbrowser-alpha-macos: submodule-update
	$(rbm) build release --target alpha --target browser-macos --target mullvadbrowser

mullvadbrowser-alpha-src: submodule-update
	$(rbm) build release --target alpha --target browser-src --target mullvadbrowser

mullvadbrowser-nightly: submodule-update
	$(rbm) build release --target nightly --target browser-all-desktop --target mullvadbrowser

mullvadbrowser-nightly-desktop: submodule-update
	$(rbm) build release --target nightly --target browser-all-desktop --target mullvadbrowser

mullvadbrowser-nightly-linux-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-linux-x86_64 --target mullvadbrowser

mullvadbrowser-nightly-linux-x86_64-asan: submodule-update
	$(rbm) build release --target nightly --target browser-linux-x86_64-asan --target mullvadbrowser

mullvadbrowser-nightly-windows-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-windows-x86_64 --target mullvadbrowser

mullvadbrowser-nightly-macos: submodule-update
	$(rbm) build release --target nightly --target browser-macos --target mullvadbrowser

mullvadbrowser-nightly-src: submodule-update
	$(rbm) build release --target nightly --target browser-src --target mullvadbrowser

mullvadbrowser-testbuild: submodule-update
	$(rbm) build release --target testbuild --target browser-all-desktop --target mullvadbrowser

mullvadbrowser-testbuild-desktop: submodule-update
	$(rbm) build release --target testbuild --target browser-all-desktop --target mullvadbrowser

mullvadbrowser-testbuild-linux-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-x86_64 --target mullvadbrowser

mullvadbrowser-testbuild-linux-x86_64-asan: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-x86_64-asan --target mullvadbrowser

mullvadbrowser-testbuild-windows-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-windows-x86_64 --target mullvadbrowser

mullvadbrowser-testbuild-macos: submodule-update
	$(rbm) build release --target testbuild --target browser-macos --target mullvadbrowser

mullvadbrowser-testbuild-macos-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-macos-x86_64 --target mullvadbrowser

mullvadbrowser-testbuild-macos-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-macos-aarch64 --target mullvadbrowser

mullvadbrowser-testbuild-src: submodule-update
	$(rbm) build release --target testbuild --target browser-src-testbuild --target mullvadbrowser

mullvadbrowser-incrementals-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target create_unsigned_incrementals --target mullvadbrowser
	tools/update-responses/download_missing_versions release
	tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release --target mullvadbrowser

mullvadbrowser-incrementals-release-unsigned: submodule-update
	$(rbm) build release --step update_responses_config --target release --target unsigned_releases_dir --target mullvadbrowser
	$(rbm) build release --step link_old_mar_filenames --target release --target unsigned_releases_dir --target mullvadbrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release --target mullvadbrowser

mullvadbrowser-incrementals-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target create_unsigned_incrementals --target mullvadbrowser
	tools/update-responses/download_missing_versions alpha
	tools/update-responses/gen_incrementals alpha
	$(rbm) build release --step hash_incrementals --target alpha --target mullvadbrowser

mullvadbrowser-incrementals-alpha-unsigned: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target unsigned_releases_dir --target mullvadbrowser
	$(rbm) build release --step link_old_mar_filenames --target alpha --target unsigned_releases_dir --target mullvadbrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals alpha
	$(rbm) build release --step hash_incrementals --target alpha --target torbrowser

mullvadbrowser-incrementals-nightly: submodule-update
	$(rbm) build release --step update_responses_config --target nightly --target mullvadbrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals nightly
	$(rbm) build release --step hash_incrementals --target nightly --target mullvadbrowser

mullvadbrowser-update_responses-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target signed --target mullvadbrowser
	$(rbm) build release --step create_update_responses_tar --target release --target signed --target mullvadbrowser

mullvadbrowser-update_responses-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target signed --target mullvadbrowser
	$(rbm) build release --step create_update_responses_tar --target alpha --target signed --target mullvadbrowser

mullvadbrowser-dmg2mar-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target signed --target mullvadbrowser
	$(rbm) build release --step dmg2mar --target release --target signed --target mullvadbrowser
	tools/update-responses/download_missing_versions release
	CHECK_CODESIGNATURE_EXISTS=1 MAR_SKIP_EXISTING=1 tools/update-responses/gen_incrementals release

mullvadbrowser-dmg2mar-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target signed --target mullvadbrowser
	$(rbm) build release --step dmg2mar --target alpha --target signed --target mullvadbrowser
	tools/update-responses/download_missing_versions alpha
	CHECK_CODESIGNATURE_EXISTS=1 MAR_SKIP_EXISTING=1 tools/update-responses/gen_incrementals alpha

mullvadbrowser-compare-windows-signed-unsigned-release: submodule-update
	$(rbm) build release --step compare_windows_signed_unsigned_exe --target release --target signed --target mullvadbrowser

mullvadbrowser-compare-windows-signed-unsigned-alpha: submodule-update
	$(rbm) build release --step compare_windows_signed_unsigned_exe --target alpha --target signed --target mullvadbrowser

mullvadbrowser-compare-mar-signed-unsigned-release: submodule-update
	$(rbm) build release --step compare_mar_signed_unsigned --target release --target signed --target mullvadbrowser

mullvadbrowser-compare-mar-signed-unsigned-alpha: submodule-update
	$(rbm) build release --step compare_mar_signed_unsigned --target alpha --target signed --target mullvadbrowser


############################
# Toolchain Update Targets #
############################

list_translation_updates-release:
	$(rbm) showconf --target release --step list_updates translation list_updates

list_translation_updates-alpha:
	$(rbm) showconf --target alpha --step list_updates translation list_updates

list_toolchain_updates-firefox-linux: submodule-update
	$(rbm) build firefox --step list_toolchain_updates --target nightly --target torbrowser-linux-x86_64

list_toolchain_updates-firefox-windows: submodule-update
	$(rbm) build firefox --step list_toolchain_updates --target nightly --target torbrowser-windows-x86_64

list_toolchain_updates-firefox-macos: submodule-update
	$(rbm) build firefox --step list_toolchain_updates --target nightly --target torbrowser-macos

list_toolchain_updates-application-services: submodule-update
	$(rbm) build application-services --step list_toolchain_updates --target nightly --target torbrowser-android-armv7

list_toolchain_updates-geckoview: submodule-update
	$(rbm) build geckoview --step list_toolchain_updates --target nightly --target torbrowser-android-armv7

list_toolchain_updates-firefox-android: submodule-update
	$(rbm) build firefox-android --step list_toolchain_updates --target nightly --target torbrowser-android-armv7

create_glean_deps_tarball: submodule-update
	 $(rbm) build glean --step create_glean_deps_tarball --target alpha --target torbrowser-android-armv7

create_glean_deps_tarball-with_torsocks: submodule-update
	$(rbm) build glean --step create_glean_deps_tarball --target alpha --target torbrowser-android-armv7 --target with_torsocks

get_gradle_dependencies_list-fenix: submodule-update
	$(rbm) build fenix --step get_gradle_dependencies_list --target nightly --target torbrowser-android-armv7

get_gradle_dependencies_list-application-services: submodule-update
	$(rbm) build application-services --step get_gradle_dependencies_list --target nightly --target torbrowser-android-armv7

get_gradle_dependencies_list-android-components: submodule-update
	$(rbm) build android-components --step get_gradle_dependencies_list --target nightly --target torbrowser-android-armv7

cargo_vendor-application-services: submodule-update
	$(rbm) build application-services --step cargo_vendor --target nightly --target torbrowser-android-armv7

cargo_vendor-cbindgen: submodule-update
	$(rbm) build cbindgen --step cargo_vendor --target alpha --target torbrowser-linux-x86_64

cargo_vendor-wasm-bindgen: submodule-update
	$(rbm) build wasm-bindgen --step cargo_vendor --target alpha --target torbrowser-linux-x86_64

cargo_vendor-lox: submodule-update
	$(rbm) build lox-wasm --step cargo_vendor --target alpha --target torbrowser-linux-x86_64

go_vendor-snowflake-alpha: submodule-update
	$(rbm) build snowflake --step go_vendor --target alpha --target torbrowser-linux-x86_64

go_vendor-conjure-alpha: submodule-update
	$(rbm) build conjure --step go_vendor --target alpha --target torbrowser-linux-x86_64

go_vendor-webtunnel-alpha: submodule-update
	$(rbm) build webtunnel --step go_vendor --target alpha --target torbrowser-linux-x86_64

go_vendor-lyrebird-alpha: submodule-update
	$(rbm) build lyrebird --step go_vendor --target alpha --target torbrowser-linux-x86_64


#############
# rcodesign #
#############

rcodesign: submodule-update
	$(rbm) build --target release --target torbrowser-linux-x86_64 rcodesign

rcodesign-filename: submodule-update
	$(rbm) showconf --target release --target torbrowser-linux-x86_64 rcodesign filename

cargo_vendor-rcodesign: submodule-update
	$(rbm) build rcodesign --step cargo_vendor --target release --target torbrowser-linux-x86_64


##################
# Common Targets #
##################

submodule-update:
	git submodule update --init

# requires tpo_user variable be set in rbm.local.conf
torbrowser-upload-sha256sums-release: submodule-update
	$(rbm) build release --step upload_sha256sums --target release --target torbrowser

# requires tpo_user variable be set in rbm.local.conf
torbrowser-upload-sha256sums-alpha: submodule-update
	$(rbm) build release --step upload_sha256sums --target alpha --target torbrowser

torbrowser-signtag-release: submodule-update
	$(rbm) build release --step signtag --target release --target torbrowser

torbrowser-signtag-alpha: submodule-update
	$(rbm) build release --step signtag --target alpha --target torbrowser

# requires tpo_user variable be set in rbm.local.conf
mullvadbrowser-upload-sha256sums-release: submodule-update
	$(rbm) build release --step upload_sha256sums --target release --target mullvadbrowser

# requires tpo_user variable be set in rbm.local.conf
mullvadbrowser-upload-sha256sums-alpha: submodule-update
	$(rbm) build release --step upload_sha256sums --target alpha --target mullvadbrowser

mullvadbrowser-signtag-release: submodule-update
	$(rbm) build release --step signtag --target release --target mullvadbrowser

mullvadbrowser-signtag-alpha: submodule-update
	$(rbm) build release --step signtag --target alpha --target mullvadbrowser

fetch: submodule-update
	$(rbm) fetch

clean: submodule-update
	./tools/clean-old

clean-dry-run: submodule-update
	./tools/clean-old --dry-run
