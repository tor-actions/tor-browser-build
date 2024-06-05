# Avoid provides/requires from private libraries
%global privlibs             libfreeblpriv3
%global privlibs %{privlibs}|libipcclientcerts
%global privlibs %{privlibs}|liblgpllibs
%global privlibs %{privlibs}|libmozavcodec
%global privlibs %{privlibs}|libmozavutil
%global privlibs %{privlibs}|libmozgtk
%global privlibs %{privlibs}|libmozsandbox
%global privlibs %{privlibs}|libmozsqlite3
%global privlibs %{privlibs}|libmozwayland
%global privlibs %{privlibs}|libnspr4
%global privlibs %{privlibs}|libnss3
%global privlibs %{privlibs}|libnssckbi
%global privlibs %{privlibs}|libnssutil3
%global privlibs %{privlibs}|libplc4
%global privlibs %{privlibs}|libplds4
%global privlibs %{privlibs}|libsmime3
%global privlibs %{privlibs}|libsoftokn3
%global privlibs %{privlibs}|libssl3
%global privlibs %{privlibs}|libstdc\\+\\+
%global privlibs %{privlibs}|libxul
%global __provides_exclude ^(%{privlibs})\\.so
%global __requires_exclude ^(%{privlibs})\\.so

Summary: [% c("var/display_name") %]
Name:    [% c("var/system_pkg/pkg_name") %]
Version: [% c("var/system_pkg/pkg_version") %]
Release: [% c("var/system_pkg/pkg_revision") %]
URL:     [% c("var/system_pkg/pkg_url") %]
License: [% c("var/system_pkg/spdx_license") %]
Source0: Makefile
Source1: [% c("var/system_pkg/pkg_name") %].desktop
[% IF c("var/browser-linux-x86_64") -%]
Source2: %{name}-linux-x86_64-%{version}.tar.xz
[% END -%]
[% IF c("var/browser-linux-i686") -%]
Source3: %{name}-linux-i386-%{version}.tar.xz
[% END -%]

%description
[% c("var/system_pkg/pkg_description") %]

%prep
mkdir -p "%name-%version"
cd "%name-%version"
cp %{_sourcedir}/Makefile .
cp %{_sourcedir}/[% c("var/system_pkg/pkg_name") %].desktop .
mkdir %{_arch}
tar -C %{_arch} --strip-components=1 -xf %{_sourcedir}/%{name}-linux-%{_arch}-%{version}.tar.xz

%build
cd "%name-%version"
DEB_TARGET_ARCH=%{_arch} make build

%install
cd "%name-%version"
DEB_TARGET_ARCH=%{_arch} make install DESTDIR="$RPM_BUILD_ROOT"

%files
%defattr(-,root,root)
/[% c('var/system_pkg/install_path') %]
/usr/bin/[% c('var/system_pkg/pkg_name') %]
/usr/share/applications/[% c("var/system_pkg/pkg_name") %].desktop
/usr/share/icons/hicolor/16x16/apps/[% c("var/system_pkg/pkg_name") %].png
/usr/share/icons/hicolor/32x32/apps/[% c("var/system_pkg/pkg_name") %].png
/usr/share/icons/hicolor/48x48/apps/[% c("var/system_pkg/pkg_name") %].png
/usr/share/icons/hicolor/64x64/apps/[% c("var/system_pkg/pkg_name") %].png
/usr/share/icons/hicolor/128x128/apps/[% c("var/system_pkg/pkg_name") %].png
/usr/share/icons/hicolor/scalable/apps/[% c("var/system_pkg/pkg_name") %].svg
