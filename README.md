# eopp-dev-vm

Vagrant configuration describing a VM for developing libeopp-based projects.

The VM is based on Ubuntu 18.04 and includes a basic set of build dependencies,
including:

* [bazelisk][bazelisk] wrapper for [bazel][bazel]
* [microk8s][microk8s] kubernetes distribution
* [kubectl][kubectl]

By default, two network ports are forwarded into the VM:

* host 8080 &rarr; guest 80
* host 8081 &rarr; guest 443

# Usage

To start and get a shell in the VM:

1. Check the Vagrantfile and adjust `vb.cpus` and `vb.memory` to appropriate
   values for your system
2. `vagrant up`
3. `vagrant ssh`

Any project sources may now be cloned and built.

## Post-creation tasks

Some tasks which may be convenient or useful for a more complete development
environment:

* Copy or generate an SSH key in `/home/vagrant/.ssh`
* Copy or add k8s contexts to `/home/vagrant/.kube/config`
* Install a desktop environment, e.g. `ubuntu-desktop` or `xubuntu-desktop`,
  and IDE
  * Note: the 'vagrant' user can log in with password `vagrant`
  * Note: to start the UI with vagrant, uncomment `vb.gui` in the Vagrantfile
* Add [proxy config to microk8s][microk8s-proxy] 
* Add microk8s addons, such as a Docker registry: see `microk8s.enable --help`
  * For example: `microk8s.enable dns ingress registry storage`

[bazelisk]: https://github.com/philwo/bazelisk
[kubectl]: https://kubernetes.io/docs/reference/kubectl/overview/
[bazel]: https://bazel.build/
[microk8s]: https://microk8s.io/
[microk8s-proxy]: https://microk8s.io/docs/#deploy-behind-a-proxy