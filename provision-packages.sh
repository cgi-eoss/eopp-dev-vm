#!/usr/bin/env bash

set -eu

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

function install_missing() {
  not_installed=()
  for pkg in "$@"; do
    if ! dpkg --get-selections "$pkg" 2>&1 | grep -q 'install$'; then
      not_installed+=("$pkg")
    fi
  done

  if [ -n "${not_installed[*]}" ]; then
    printf "\n\nInstalling missing required packages: %s\n" "${not_installed[*]}"
    apt update && apt install -y --no-install-recommends "${not_installed[@]}"
  else
    printf "\n\nAll required packages already installed\n"
  fi
}

REQUIRED_PKGS_1=(
  apt-transport-https
  autoconf
  automake
  bash-completion
  build-essential
  curl
  firefox
  git
  git-lfs
  gnupg
  jq
  libdbus-glib-1-2
  libgtk-3-0
  liblzma-dev
  libpng-dev
  libxt6
  linux-headers-generic
  openjdk-11-jdk
  openssh-server
  python-is-python3
  python2
  python2-dev
  python-setuptools
  python-pip-whl
  python3
  python3-dev
  python3-pip
  python3-setuptools
  python3-wheel
  locales
  unzip
  zip
)

REQUIRED_PKGS_2=(
  bazel
  kubectl
  nodejs
  yarn
)

install_missing "${REQUIRED_PKGS_1[@]}"

BAZELISK_VER="1.11.0"
NODE_VER="node_12.x"

# Set up additional apt repos
curl -sL https://storage.googleapis.com/bazel-apt/doc/apt-key.pub.gpg | apt-key add -
echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" >/etc/apt/sources.list.d/bazel.list
curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
curl -sL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
echo "deb https://deb.nodesource.com/${NODE_VER} focal main" >/etc/apt/sources.list.d/nodesource.list
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" >/etc/apt/sources.list.d/yarn.list

curl -sL "https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VER}/bazelisk-linux-amd64" -o /usr/local/bin/bazelisk
chmod +x /usr/local/bin/bazelisk
ln -snf /usr/local/bin/bazelisk /usr/local/bin/bazel

install_missing "${REQUIRED_PKGS_2[@]}"
