rbm=./rbm/rbm
browser_default_channel=$(shell $(rbm) showconf release var/browser_default_channel)

.PHONY: torbrowser mullvadbrowser
all: torbrowser mullvadbrowser

#######################
# Tor Browser Targets #
#######################

torbrowser: submodule-update
	@echo Building torbrowser-$(browser_default_channel)
	$(MAKE) torbrowser-$(browser_default_channel)
	@echo Building incrementals for torbrowser-$(browser_default_channel)
	$(MAKE) torbrowser-incrementals-$(browser_default_channel)

torbrowser-release: submodule-update
	$(rbm) build release --target release --target browser-all --target torbrowser

torbrowser-release-desktop: submodule-update
	$(rbm) build release --target release --target browser-all-desktop --target torbrowser

torbrowser-release-android: submodule-update
	$(rbm) build release --target release --target browser-all-android --target torbrowser

torbrowser-release-android-armv7: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-android-armv7 --target torbrowser

torbrowser-release-android-aarch64: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-android-aarch64 --target torbrowser

torbrowser-release-android-x86_64: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-android-x86_64 --target torbrowser

torbrowser-release-linux-x86_64: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-linux-x86_64 --target torbrowser

torbrowser-release-linux-x86_64-asan: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-linux-x86_64-asan --target torbrowser

torbrowser-release-linux-aarch64: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-linux-aarch64 --target torbrowser

torbrowser-release-windows-i686: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-windows-i686 --target torbrowser

torbrowser-release-windows-x86_64: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-windows-x86_64 --target torbrowser

torbrowser-release-macos: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-macos --target torbrowser

torbrowser-release-src: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-src --target torbrowser

torbrowser-alpha: submodule-update
	$(rbm) build release --target alpha --target browser-all --target torbrowser

torbrowser-alpha-desktop: submodule-update
	$(rbm) build release --target alpha --target browser-all-desktop --target torbrowser

torbrowser-alpha-android: submodule-update
	$(rbm) build release --target alpha --target browser-all-android --target torbrowser

torbrowser-alpha-android-armv7: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-android-armv7 --target torbrowser

torbrowser-alpha-android-aarch64: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-android-aarch64 --target torbrowser

torbrowser-alpha-android-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-android-x86_64 --target torbrowser

torbrowser-alpha-linux-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-linux-x86_64 --target torbrowser

torbrowser-alpha-linux-x86_64-asan: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-linux-x86_64-asan --target torbrowser

torbrowser-alpha-linux-aarch64: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-linux-aarch64 --target torbrowser

torbrowser-alpha-windows-i686: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-windows-i686 --target torbrowser

torbrowser-alpha-windows-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-windows-x86_64 --target torbrowser

torbrowser-alpha-macos: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-macos --target torbrowser

torbrowser-alpha-src: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-src --target torbrowser

torbrowser-nightly: submodule-update
	$(rbm) build release --target nightly --target browser-all --target torbrowser

torbrowser-nightly-desktop: submodule-update
	$(rbm) build release --target nightly --target browser-all-desktop --target torbrowser

torbrowser-nightly-android: submodule-update
	$(rbm) build release --target nightly --target browser-all-android --target torbrowser

torbrowser-nightly-android-armv7: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-android-armv7 --target torbrowser

torbrowser-nightly-android-aarch64: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-android-aarch64 --target torbrowser

torbrowser-nightly-android-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-android-x86_64 --target torbrowser

torbrowser-nightly-linux-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-linux-x86_64 --target torbrowser

torbrowser-nightly-linux-x86_64-asan: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-linux-x86_64-asan --target torbrowser

torbrowser-nightly-linux-aarch64: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-linux-aarch64 --target torbrowser

torbrowser-nightly-windows-i686: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-windows-i686 --target torbrowser

torbrowser-nightly-windows-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-windows-x86_64 --target torbrowser

torbrowser-nightly-macos: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-macos --target torbrowser

torbrowser-nightly-src: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-src --target torbrowser

torbrowser-testbuild: submodule-update
	$(rbm) build release --target testbuild --target browser-all --target torbrowser

torbrowser-testbuild-desktop: submodule-update
	$(rbm) build release --target testbuild --target browser-all-desktop --target torbrowser

torbrowser-testbuild-android: submodule-update
	$(rbm) build release --target testbuild --target browser-all-android --target torbrowser

torbrowser-testbuild-android-armv7: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-android-armv7 --target torbrowser

torbrowser-testbuild-android-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-android-aarch64 --target torbrowser

torbrowser-testbuild-android-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-android-x86_64 --target torbrowser

torbrowser-testbuild-linux-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-linux-x86_64 --target torbrowser

torbrowser-testbuild-linux-x86_64-asan: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-linux-x86_64-asan --target torbrowser

torbrowser-testbuild-linux-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-linux-aarch64 --target torbrowser

torbrowser-testbuild-windows-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-windows-x86_64 --target torbrowser

torbrowser-testbuild-windows-i686: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-windows-i686 --target torbrowser

torbrowser-testbuild-macos: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-macos --target torbrowser

torbrowser-testbuild-macos-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-macos-x86_64 --target torbrowser

torbrowser-testbuild-macos-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-macos-aarch64 --target torbrowser

torbrowser-testbuild-src: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-src-testbuild --target torbrowser

torbrowser-incrementals-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target create_unsigned_incrementals --target torbrowser
	tools/update-responses/download_missing_versions release
	tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release --target torbrowser

torbrowser-incrementals-release-unsigned: submodule-update
	$(rbm) build release --step update_responses_config --target release --target unsigned_releases_dir --target torbrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release --target torbrowser

torbrowser-incrementals-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target create_unsigned_incrementals --target torbrowser
	tools/update-responses/download_missing_versions alpha
	tools/update-responses/gen_incrementals alpha
	$(rbm) build release --step hash_incrementals --target alpha --target torbrowser

torbrowser-incrementals-alpha-unsigned: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target unsigned_releases_dir --target torbrowser
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


###########################
# Mullvad Browser Targets #
###########################

mullvadbrowser: submodule-update
	@echo Building mullvadbrowser-$(browser_default_channel)
	$(MAKE) mullvadbrowser-$(browser_default_channel)
	@echo Building incrementals for mullvadbrowser-$(browser_default_channel)
	$(MAKE) mullvadbrowser-incrementals-$(browser_default_channel)

mullvadbrowser-release: submodule-update
	$(rbm) build release --target release --target browser-all --target mullvadbrowser

mullvadbrowser-release-linux-x86_64: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-linux-x86_64 --target mullvadbrowser

mullvadbrowser-release-linux-x86_64-asan: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-linux-x86_64-asan --target mullvadbrowser

mullvadbrowser-release-linux-aarch64: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-linux-aarch64 --target mullvadbrowser

mullvadbrowser-release-windows-x86_64: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-windows-x86_64 --target mullvadbrowser

mullvadbrowser-release-macos: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-macos --target mullvadbrowser

mullvadbrowser-release-src: submodule-update
	$(rbm) build release --target release --target browser-single-platform --target browser-src --target mullvadbrowser

mullvadbrowser-alpha: submodule-update
	$(rbm) build release --target alpha --target browser-all --target mullvadbrowser

mullvadbrowser-alpha-linux-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-linux-x86_64 --target mullvadbrowser

mullvadbrowser-alpha-linux-x86_64-asan: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-linux-x86_64-asan --target mullvadbrowser

mullvadbrowser-alpha-linux-aarch64: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-linux-aarch64 --target mullvadbrowser

mullvadbrowser-alpha-windows-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-windows-x86_64 --target mullvadbrowser

mullvadbrowser-alpha-macos: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-macos --target mullvadbrowser

mullvadbrowser-alpha-src: submodule-update
	$(rbm) build release --target alpha --target browser-single-platform --target browser-src --target mullvadbrowser

mullvadbrowser-nightly: submodule-update
	$(rbm) build release --target nightly --target browser-all --target mullvadbrowser

mullvadbrowser-nightly-linux-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-linux-x86_64 --target mullvadbrowser

mullvadbrowser-nightly-linux-x86_64-asan: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-linux-x86_64-asan --target mullvadbrowser

mullvadbrowser-nightly-linux-aarch64: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-linux-aarch64 --target mullvadbrowser

mullvadbrowser-nightly-windows-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-windows-x86_64 --target mullvadbrowser

mullvadbrowser-nightly-macos: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-macos --target mullvadbrowser

mullvadbrowser-nightly-src: submodule-update
	$(rbm) build release --target nightly --target browser-single-platform --target browser-src --target mullvadbrowser

mullvadbrowser-testbuild: submodule-update
	$(rbm) build release --target testbuild --target browser-all --target mullvadbrowser

mullvadbrowser-testbuild-linux-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-linux-x86_64 --target mullvadbrowser

mullvadbrowser-testbuild-linux-x86_64-asan: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-linux-x86_64-asan --target mullvadbrowser

mullvadbrowser-testbuild-linux-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-linux-aarch64 --target mullvadbrowser

mullvadbrowser-testbuild-windows-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-windows-x86_64 --target mullvadbrowser

mullvadbrowser-testbuild-macos: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-macos --target mullvadbrowser

mullvadbrowser-testbuild-macos-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-macos-x86_64 --target mullvadbrowser

mullvadbrowser-testbuild-macos-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-macos-aarch64 --target mullvadbrowser

mullvadbrowser-testbuild-src: submodule-update
	$(rbm) build release --target testbuild --target browser-single-platform --target browser-src-testbuild --target mullvadbrowser

mullvadbrowser-incrementals-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target create_unsigned_incrementals --target mullvadbrowser
	tools/update-responses/download_missing_versions release
	tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release --target mullvadbrowser

mullvadbrowser-incrementals-release-unsigned: submodule-update
	$(rbm) build release --step update_responses_config --target release --target unsigned_releases_dir --target mullvadbrowser
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release --target mullvadbrowser

mullvadbrowser-incrementals-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target create_unsigned_incrementals --target mullvadbrowser
	tools/update-responses/download_missing_versions alpha
	tools/update-responses/gen_incrementals alpha
	$(rbm) build release --step hash_incrementals --target alpha --target mullvadbrowser

mullvadbrowser-incrementals-alpha-unsigned: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target unsigned_releases_dir --target mullvadbrowser
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

#############################
# Building upstream firefox #
#############################

firefox-linux-x86_64: submodule-update
	$(rbm) build firefox --target alpha --target firefoxbrowser-linux-x86_64

firefox-linux-aarch64: submodule-update
	$(rbm) build firefox --target alpha --target firefoxbrowser-linux-arch64

firefox-windows-x86_64: submodule-update
	$(rbm) build firefox --target alpha --target firefoxbrowser-windows-x86_64

firefox-windows-i686: submodule-update
	$(rbm) build firefox --target alpha --target firefoxbrowser-windows-i686

firefox-macos-aarch64: submodule-update
	$(rbm) build firefox --target alpha --target firefoxbrowser-macos-aarch64

firefox-macos-x86_64: submodule-update
	$(rbm) build firefox --target alpha --target firefoxbrowser-macos-x86_64

geckoview-android-aarch64: submodule-update
	$(rbm) build geckoview --target testbuild --target alpha --target firefoxbrowser-android-aarch64


############################
# Toolchain Update Targets #
############################

list_translation_updates-release:
	$(rbm) showconf --target release --step list_updates translation list_updates

list_translation_updates-alpha:
	$(rbm) showconf --target alpha --step list_updates translation list_updates

list_toolchain_updates:
	tools/list_toolchain_updates

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

create_glean_deps_tarball: submodule-update
	 $(rbm) build glean-parser --target alpha --target torbrowser-android-armv7

create_glean_deps_tarball-with_torsocks: submodule-update
	$(rbm) build glean-parser --target alpha --target torbrowser-android-armv7 --target with_torsocks

get_gradle_dependencies_list-application-services: submodule-update
	$(rbm) build application-services --step get_gradle_dependencies_list --target nightly --target torbrowser-android-armv7

cargo_vendor-application-services: submodule-update
	$(rbm) build application-services --step cargo_vendor --target nightly --target torbrowser-android-armv7

cargo_vendor-cbindgen: submodule-update
	$(rbm) build cbindgen --step cargo_vendor --target alpha --target torbrowser-linux-x86_64

cargo_vendor-wasm-bindgen: submodule-update
	$(rbm) build wasm-bindgen --step cargo_vendor --target alpha --target torbrowser-linux-x86_64

cargo_vendor-lox: submodule-update
	$(rbm) build lox-wasm --step cargo_vendor --target alpha --target torbrowser-linux-x86_64

cargo_vendor-uniffi-rs: submodule-update
	$(rbm) build uniffi-rs --step cargo_vendor --target alpha --target torbrowser-linux-x86_64

cargo_vendor-glean: submodule-update
	$(rbm) build glean --step cargo_vendor --target alpha --target torbrowser-linux-x86_64

go_vendor-conjure: submodule-update
	$(rbm) build conjure --step go_vendor --target alpha --target torbrowser-linux-x86_64

go_vendor-lyrebird: submodule-update
	$(rbm) build lyrebird --step go_vendor --target alpha --target torbrowser-linux-x86_64

go_vendor-go-licenses: submodule-update
	$(rbm) build go-licenses --step go_vendor --target alpha --target torbrowser-linux-x86_64

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
	@git submodule update --init

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

# requires var/devmole_auth_token to be set in rbm.local.conf
torbrowser-kick-devmole-build: submodule-update
	$(rbm) build release --step kick_devmole_build --target torbrowser

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

# requires var/devmole_auth_token to be set in rbm.local.conf
mullvadbrowser-kick-devmole-build: submodule-update
	$(rbm) build release --step kick_devmole_build --target mullvadbrowser

fetch: submodule-update
	$(rbm) fetch
	$(rbm) fetch firefox --target mullvadbrowser

list-unused-projects: submodule-update
	./tools/list-unused-projects

clean: submodule-update
	./tools/clean-old

clean-dry-run: submodule-update
	./tools/clean-old --dry-run
