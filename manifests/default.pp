node default {

  # Install basic dev environment packages
  ensure_packages([
    'apt-transport-https',
    'build-essential',
    'curl',
    'git',
    'liblzma-dev',
    'openjdk-8-jdk',
    'python',
    'snapd',
    'zip',
    'unzip',
  ], { ensure => latest })

  # Install kubernetes-related snaps
  [ 'microk8s', 'kubectl' ].each |String $snap| {
    exec { "install_$snap":
      command => "/usr/bin/snap install $snap --classic",
      creates => "/var/snap/$snap",
    }
  }

  # Install bazelisk bazel wrapper
  $bazelisk_version = '0.0.7'
  $bazelisk_path = '/usr/local/bin/bazelisk'
  archive { 'bazelisk':
    path   => $bazelisk_path,
    source => "https://github.com/philwo/bazelisk/releases/download/v$bazelisk_version/bazelisk-linux-amd64",
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
