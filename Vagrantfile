# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'concurrent'

# Required plugins:
# * vagrant-puppet-install
# * vagrant-vbguest

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.hostname = "eopp-dev-vm"

  if Vagrant.has_plugin?("vagrant-timezone")
    config.timezone.value = :host
  end

  # Generic port forwarding for HTTP/HTTPS
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8081

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    vb.name = "eopp-dev-vm"

    # Reduce disk overhead when multiple dev-vms (or other VMs based on this config.vm.box) are used
    vb.linked_clone = true

    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true

    # Automatically determine number of CPUs to use
    vb.cpus = Concurrent.processor_count

    # Customize the amount of memory on the VM - adjust as high as possible for your system!
    vb.memory = "2048"

    # Other system customisations
    vb.customize ["modifyvm", :id, "--hpet", "on"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--nestedpaging", "on"]
    vb.customize ["modifyvm", :id, "--largepages", "on"]
    vb.customize ["modifyvm", :id, "--vtxvpid", "on"]
    vb.customize ["modifyvm", :id, "--vtxux", "on"]
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
  end

  if Vagrant.has_plugin?("vagrant-puppet-install")
    config.puppet_install.puppet_version = :latest
  end

  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "modules"
  end

end
