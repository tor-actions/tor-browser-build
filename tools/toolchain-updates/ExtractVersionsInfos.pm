#!/usr/bin/perl -w
package ExtractVersionsInfos;

use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/*version_infos *rbm_os_target set_version_info
                 get_version_info set_rbm_info set_error as_array/;

our %version_infos;

our %rbm_os_target = (
  linux => 'torbrowser-linux-x86_64',
  windows => 'torbrowser-windows-x86_64',
  macos => 'torbrowser-macos-aarch64',
  android => 'torbrowser-android-aarch64',
);

sub set_version_info {
  my ($name, $value) = @_;
  $version_infos{$name}->{expected_value} = $value;
}

sub get_version_info {
  return $version_infos{$_[0]}->{expected_value};
}

sub set_rbm_info {
  my ($name, $rbm_info) = @_;
  $version_infos{$name}->{rbm_info} = $rbm_info;
}

sub set_error {
  $version_infos{$_[0]}->{error} = 1;
}

sub as_array {
  return [] unless defined $_[0];
  return ref $_[0] eq 'ARRAY' ? $_[0] : [ $_[0] ];
}

1;
