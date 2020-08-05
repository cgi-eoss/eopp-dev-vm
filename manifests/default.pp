node default {

  # Install bazel (for autocompletion only; bazelisk manages running bazel versions)
  include apt
  apt::key { 'bazel-release.pub':
    id     => '71A1D0EFCFEB6281FD0437C93D5919B448457EE0',
    source => 'https://bazel.build/bazel-release.pub.gpg',
  } ->
  apt::source { 'bazel':
    location     => 'https://storage.googleapis.com/bazel-apt',
	release      => 'stable',
	repos        => 'jdk1.8',
	architecture => 'amd64'
  }
  
  # Install basic dev environment packages
  ensure_packages([
    'apt-transport-https',
    'autoconf',
	'bazel',
    'build-essential',
    'curl',
    'git',
    'liblzma-dev',
    'libpng-dev',
    'openjdk-11-jdk',
    'python',
    'snapd',
    'zip',
    'unzip',
  ], {
    ensure => latest,
	require => [Apt::Source['bazel'], Class['apt::update']]
  })

  # Install kubernetes-related snaps
  [ 'microk8s', 'kubectl' ].each |String $snap| {
    exec { "install_$snap":
      command => "/usr/bin/snap install $snap --classic",
      creates => "/var/snap/$snap",
    }
  }

  # Install bazelisk bazel wrapper
  $bazelisk_version = '1.5.0'
  $bazelisk_path = '/usr/local/bin/bazelisk'
  archive { 'bazelisk':
    path   => $bazelisk_path,
    source => "https://github.com/bazelbuild/bazelisk/releases/download/v$bazelisk_version/bazelisk-linux-amd64",
  } ->
  file { $bazelisk_path:
    ensure => present,
    mode   => '0755',
  } ->
  file { '/usr/local/bin/bazel':
    ensure => link,
    target => $bazelisk_path,
  }

}
