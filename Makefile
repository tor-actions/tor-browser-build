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

signtag-release: submodule-update
	$(rbm) build release --step signtag --target release

signtag-alpha: submodule-update
	$(rbm) build release --step signtag --target alpha

incrementals-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target create_unsigned_incrementals
	tools/update-responses/download_missing_versions release
	tools/update-responses/gen_incrementals release
	$(rbm) build release --step hash_incrementals --target release

incrementals-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target create_unsigned_incrementals
	tools/update-responses/download_missing_versions alpha
	tools/update-responses/gen_incrementals alpha
	$(rbm) build release --step hash_incrementals --target alpha

incrementals-nightly: submodule-update
	$(rbm) build release --step update_responses_config --target nightly
	NO_CODESIGNATURE=1 tools/update-responses/gen_incrementals nightly
	$(rbm) build release --step hash_incrementals --target nightly

update_responses-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target signed
	$(rbm) build release --step create_update_responses_tar --target release --target signed

update_responses-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target signed
	$(rbm) build release --step create_update_responses_tar --target alpha --target signed

dmg2mar-release: submodule-update
	$(rbm) build release --step update_responses_config --target release --target signed
	$(rbm) build release --step dmg2mar --target release --target signed
	tools/update-responses/download_missing_versions release
	CHECK_CODESIGNATURE_EXISTS=1 MAR_SKIP_EXISTING=1 tools/update-responses/gen_incrementals release

dmg2mar-alpha: submodule-update
	$(rbm) build release --step update_responses_config --target alpha --target signed
	$(rbm) build release --step dmg2mar --target alpha --target signed
	tools/update-responses/download_missing_versions alpha
	CHECK_CODESIGNATURE_EXISTS=1 MAR_SKIP_EXISTING=1 tools/update-responses/gen_incrementals alpha

list_toolchain_updates-fenix: submodule-update
	$(rbm) build fenix --step list_toolchain_updates --target nightly --target torbrowser-android-armv7

list_toolchain_updates-firefox-linux: submodule-update
	$(rbm) build firefox --step list_toolchain_updates --target nightly --target torbrowser-linux-x86_64

list_toolchain_updates-firefox-windows: submodule-update
	$(rbm) build firefox --step list_toolchain_updates --target nightly --target torbrowser-windows-x86_64

list_toolchain_updates-firefox-macos: submodule-update
	$(rbm) build firefox --step list_toolchain_updates --target nightly --target torbrowser-macos

list_toolchain_updates-android-components: submodule-update
	$(rbm) build android-components --step list_toolchain_updates --target nightly --target torbrowser-android-armv7

list_toolchain_updates-application-services: submodule-update
	$(rbm) build application-services --step list_toolchain_updates --target nightly --target torbrowser-android-armv7

list_toolchain_updates-geckoview: submodule-update
	$(rbm) build geckoview --step list_toolchain_updates --target nightly --target torbrowser-android-armv7

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

cargo_vendor-cbindgen-android: submodule-update
	$(rbm) build cbindgen --step cargo_vendor --target nightly --target torbrowser-android-armv7

cargo_vendor-cbindgen: submodule-update
	$(rbm) build cbindgen --step cargo_vendor --target nightly --target torbrowser-linux-x86_64

cargo_vendor-lucetc: submodule-update
	$(rbm) build lucetc --step cargo_vendor --target nightly --target torbrowser-linux-x86_64

cargo_vendor-uniffi-rs: submodule-update
	$(rbm) build uniffi-rs --step cargo_vendor --target nightly --target torbrowser-linux-x86_64


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


##################
# Common Targets #
##################

submodule-update:
	git submodule update --init

fetch: submodule-update
	$(rbm) fetch

clean: submodule-update
	./tools/clean-old

clean-dry-run: submodule-update
	./tools/clean-old --dry-run
