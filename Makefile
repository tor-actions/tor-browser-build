rbm=./rbm/rbm

all: release

release: submodule-update
	$(rbm) build release --target release --target torbrowser-all

release-android: submodule-update
	$(rbm) build release --target release --target torbrowser-all-android

release-android-armv7: submodule-update
	$(rbm) build release --target release --target torbrowser-android-armv7

release-android-x86: submodule-update
	$(rbm) build release --target release --target torbrowser-android-x86

release-android-x86_64: submodule-update
	$(rbm) build release --target release --target torbrowser-android-x86_64

release-android-aarch64: submodule-update
	$(rbm) build release --target release --target torbrowser-android-aarch64

release-linux-x86_64: submodule-update
	$(rbm) build release --target release --target torbrowser-linux-x86_64

release-linux-x86_64-asan: submodule-update
	$(rbm) build release --target release --target torbrowser-linux-x86_64-asan

release-linux-i686: submodule-update
	$(rbm) build release --target release --target torbrowser-linux-i686

release-windows-i686: submodule-update
	$(rbm) build release --target release --target torbrowser-windows-i686

release-windows-x86_64: submodule-update
	$(rbm) build release --target release --target torbrowser-windows-x86_64

release-osx-x86_64: submodule-update
	$(rbm) build release --target release --target torbrowser-osx-x86_64

release-src: submodule-update
	$(rbm) build release --target release --target torbrowser-src

alpha: submodule-update
	$(rbm) build release --target alpha --target torbrowser-all

alpha-android: submodule-update
	$(rbm) build release --target alpha --target torbrowser-all-android

alpha-android-armv7: submodule-update
	$(rbm) build release --target alpha --target torbrowser-android-armv7

alpha-android-x86: submodule-update
	$(rbm) build release --target alpha --target torbrowser-android-x86

alpha-android-x86_64: submodule-update
	$(rbm) build release --target alpha --target torbrowser-android-x86_64

alpha-android-aarch64: submodule-update
	$(rbm) build release --target alpha --target torbrowser-android-aarch64

alpha-linux-x86_64: submodule-update
	$(rbm) build release --target alpha --target torbrowser-linux-x86_64

alpha-linux-x86_64-asan: submodule-update
	$(rbm) build release --target alpha --target torbrowser-linux-x86_64-asan

alpha-linux-i686: submodule-update
	$(rbm) build release --target alpha --target torbrowser-linux-i686

alpha-windows-i686: submodule-update
	$(rbm) build release --target alpha --target torbrowser-windows-i686

alpha-windows-x86_64: submodule-update
	$(rbm) build release --target alpha --target torbrowser-windows-x86_64

alpha-osx-x86_64: submodule-update
	$(rbm) build release --target alpha --target torbrowser-osx-x86_64

alpha-src: submodule-update
	$(rbm) build release --target alpha --target torbrowser-src

nightly: submodule-update
	$(rbm) build release --target nightly --target torbrowser-all

nightly-android: submodule-update
	$(rbm) build release --target nightly --target torbrowser-all-android

nightly-android-armv7: submodule-update
	$(rbm) build release --target nightly --target torbrowser-android-armv7

nightly-android-x86: submodule-update
	$(rbm) build release --target nightly --target torbrowser-android-x86

nightly-android-x86_64: submodule-update
	$(rbm) build release --target nightly --target torbrowser-android-x86_64

nightly-android-aarch64: submodule-update
	$(rbm) build release --target nightly --target torbrowser-android-aarch64

nightly-linux-x86_64: submodule-update
	$(rbm) build release --target nightly --target torbrowser-linux-x86_64

nightly-linux-x86_64-asan: submodule-update
	$(rbm) build release --target nightly --target torbrowser-linux-x86_64-asan

nightly-linux-i686: submodule-update
	$(rbm) build release --target nightly --target torbrowser-linux-i686

nightly-windows-i686: submodule-update
	$(rbm) build release --target nightly --target torbrowser-windows-i686

nightly-windows-x86_64: submodule-update
	$(rbm) build release --target nightly --target torbrowser-windows-x86_64

nightly-osx-x86_64: submodule-update
	$(rbm) build release --target nightly --target torbrowser-osx-x86_64

nightly-src: submodule-update
	$(rbm) build release --target nightly --target torbrowser-src

testbuild: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-all

testbuild-android: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-all-android

testbuild-android-armv7: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-android-armv7

testbuild-android-x86: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-android-x86

testbuild-android-x86_64: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-android-x86_64

testbuild-android-aarch64: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-android-aarch64

testbuild-linux-x86_64: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-linux-x86_64

testbuild-linux-x86_64-asan: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-linux-x86_64-asan

testbuild-linux-i686: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-linux-i686

testbuild-windows-x86_64: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-windows-x86_64

testbuild-windows-i686: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-windows-i686

testbuild-osx-x86_64: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-osx-x86_64

testbuild-src: submodule-update
	$(rbm) build release --target testbuild --target torbrowser-src-testbuild

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
	$(rbm) build application-services --step cargo_vendor --target nightly

cargo_vendor-cbindgen-android: submodule-update
	$(rbm) build cbindgen --step cargo_vendor --target nightly --target android

cargo_vendor-cbindgen: submodule-update
	$(rbm) build cbindgen --step cargo_vendor --target nightly

cargo_vendor-lucetc: submodule-update
	$(rbm) build lucetc --step cargo_vendor --target nightly

cargo_vendor-uniffi-rs: submodule-update
	$(rbm) build uniffi-rs --step cargo_vendor --target nightly

submodule-update:
	git submodule update --init

fetch: submodule-update
	$(rbm) fetch

clean: submodule-update
	./tools/clean-old

clean-dry-run: submodule-update
	./tools/clean-old --dry-run

