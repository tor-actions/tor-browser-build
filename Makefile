rbm=./rbm/rbm

all: release

release: submodule-update
	$(rbm) build release --target release --target browser-all --target torbrowser

release-android: submodule-update
	$(rbm) build release --target release --target browser-all-android --target torbrowser

release-android-armv7: submodule-update
	$(rbm) build release --target release --target browser-android-armv7 --target torbrowser

release-android-x86: submodule-update
	$(rbm) build release --target release --target browser-android-x86 --target torbrowser

release-android-x86_64: submodule-update
	$(rbm) build release --target release --target browser-android-x86_64 --target torbrowser

release-android-aarch64: submodule-update
	$(rbm) build release --target release --target browser-android-aarch64 --target torbrowser

release-desktop: submodule-update
	$(rbm) build release --target release --target browser-all-desktop --target torbrowser

release-linux-x86_64: submodule-update
	$(rbm) build release --target release --target browser-linux-x86_64 --target torbrowser

release-linux-x86_64-asan: submodule-update
	$(rbm) build release --target release --target browser-linux-x86_64-asan --target torbrowser

release-linux-i686: submodule-update
	$(rbm) build release --target release --target browser-linux-i686 --target torbrowser

release-windows-i686: submodule-update
	$(rbm) build release --target release --target browser-windows-i686 --target torbrowser

release-windows-x86_64: submodule-update
	$(rbm) build release --target release --target browser-windows-x86_64 --target torbrowser

release-osx-x86_64: submodule-update
	$(rbm) build release --target release --target browser-osx-x86_64 --target torbrowser

release-src: submodule-update
	$(rbm) build release --target release --target browser-src --target torbrowser

alpha: submodule-update
	$(rbm) build release --target alpha --target browser-all --target torbrowser

alpha-android: submodule-update
	$(rbm) build release --target alpha --target browser-all-android --target torbrowser

alpha-android-armv7: submodule-update
	$(rbm) build release --target alpha --target browser-android-armv7 --target torbrowser

alpha-android-x86: submodule-update
	$(rbm) build release --target alpha --target browser-android-x86 --target torbrowser

alpha-android-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-android-x86_64 --target torbrowser

alpha-android-aarch64: submodule-update
	$(rbm) build release --target alpha --target browser-android-aarch64 --target torbrowser

alpha-desktop: submodule-update
	$(rbm) build release --target alpha --target browser-all-desktop --target torbrowser

alpha-linux-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-linux-x86_64 --target torbrowser

alpha-linux-x86_64-asan: submodule-update
	$(rbm) build release --target alpha --target browser-linux-x86_64-asan --target torbrowser

alpha-linux-i686: submodule-update
	$(rbm) build release --target alpha --target browser-linux-i686 --target torbrowser

alpha-windows-i686: submodule-update
	$(rbm) build release --target alpha --target browser-windows-i686 --target torbrowser

alpha-windows-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-windows-x86_64 --target torbrowser

alpha-osx-x86_64: submodule-update
	$(rbm) build release --target alpha --target browser-osx-x86_64 --target torbrowser

alpha-src: submodule-update
	$(rbm) build release --target alpha --target browser-src --target torbrowser

nightly: submodule-update
	$(rbm) build release --target nightly --target browser-all --target torbrowser

nightly-android: submodule-update
	$(rbm) build release --target nightly --target browser-all-android --target torbrowser

nightly-android-armv7: submodule-update
	$(rbm) build release --target nightly --target browser-android-armv7 --target torbrowser

nightly-android-x86: submodule-update
	$(rbm) build release --target nightly --target browser-android-x86 --target torbrowser

nightly-android-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-android-x86_64 --target torbrowser

nightly-android-aarch64: submodule-update
	$(rbm) build release --target nightly --target browser-android-aarch64 --target torbrowser

nightly-desktop: submodule-update
	$(rbm) build release --target nightly --target browser-all-desktop --target torbrowser

nightly-linux-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-linux-x86_64 --target torbrowser

nightly-linux-x86_64-asan: submodule-update
	$(rbm) build release --target nightly --target browser-linux-x86_64-asan --target torbrowser

nightly-linux-i686: submodule-update
	$(rbm) build release --target nightly --target browser-linux-i686 --target torbrowser

nightly-windows-i686: submodule-update
	$(rbm) build release --target nightly --target browser-windows-i686 --target torbrowser

nightly-windows-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-windows-x86_64 --target torbrowser

nightly-osx-x86_64: submodule-update
	$(rbm) build release --target nightly --target browser-osx-x86_64 --target torbrowser

nightly-src: submodule-update
	$(rbm) build release --target nightly --target browser-src --target torbrowser

testbuild: submodule-update
	$(rbm) build release --target testbuild --target browser-all --target torbrowser

testbuild-android: submodule-update
	$(rbm) build release --target testbuild --target browser-all-android --target torbrowser

testbuild-android-armv7: submodule-update
	$(rbm) build release --target testbuild --target browser-android-armv7 --target torbrowser

testbuild-android-x86: submodule-update
	$(rbm) build release --target testbuild --target browser-android-x86 --target torbrowser

testbuild-android-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-android-x86_64 --target torbrowser

testbuild-android-aarch64: submodule-update
	$(rbm) build release --target testbuild --target browser-android-aarch64 --target torbrowser

testbuild-desktop: submodule-update
	$(rbm) build release --target testbuild --target browser-all-desktop --target torbrowser

testbuild-linux-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-x86_64 --target torbrowser

testbuild-linux-x86_64-asan: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-x86_64-asan --target torbrowser

testbuild-linux-i686: submodule-update
	$(rbm) build release --target testbuild --target browser-linux-i686 --target torbrowser

testbuild-windows-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-windows-x86_64 --target torbrowser

testbuild-windows-i686: submodule-update
	$(rbm) build release --target testbuild --target browser-windows-i686 --target torbrowser

testbuild-osx-x86_64: submodule-update
	$(rbm) build release --target testbuild --target browser-osx-x86_64 --target torbrowser

testbuild-src: submodule-update
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
	$(rbm) build firefox --step list_toolchain_updates --target nightly --target torbrowser-osx-x86_64

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

submodule-update:
	git submodule update --init

fetch: submodule-update
	$(rbm) fetch

clean: submodule-update
	./tools/clean-old

clean-dry-run: submodule-update
	./tools/clean-old --dry-run
