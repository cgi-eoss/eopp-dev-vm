# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'concurrent'

$vm_memory ||= 2048
$vm_cpus ||= Concurrent.processor_count
$vm_gui ||= false
$disk_size ||= "64GB" # default size of the bento/ubuntu-20.04 box
$bridge_network ||= false
$bridge_gateway ||= ""

# Plugins
#
# Check if the first argument to the vagrant
# command is plugin or not to avoid the loop
if ARGV[0] != 'plugin'
  # Define the plugins in an array format
  required_plugins = [
    'vagrant-disksize',
    'vagrant-hostmanager',
    'vagrant-proxyconf',
    'vagrant-timezone',
    'vagrant-vbguest'
  ]
  plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
  if not plugins_to_install.empty?
    puts "Installing plugins: #{plugins_to_install.join(' ')}"
    if system "vagrant plugin install #{plugins_to_install.join(' ')}"
      exec "vagrant #{ARGV.join(' ')}"
    else
      abort "Installation of one or more plugins has failed. Aborting."
    end
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  config.vm.hostname = "eopp-dev-vm"

  if Vagrant.has_plugin?("vagrant-timezone")
    config.timezone.value = :host
  end

  if Vagrant.has_plugin?("vagrant-disksize")
    config.disksize.size = $disk_size
  end

  # Propagate standard proxy vars from host->VM
  # This could also be added globally in ~/.vagrant.d/Vagrantfile
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = ENV['http_proxy']
    config.proxy.https    = ENV['https_proxy']

    config.proxy.no_proxy = ((ENV['no_proxy'] || '').split(',') | ['eopp-dev-vm', '10.0.2.15', '.svc', 'localhost', '127.0.0.1']).join(',') 
  end

  # Generic port forwarding for HTTP/HTTPS
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8079

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.

  ["vmware_fusion", "vmware_workstation"].each do |vmware|
    config.vm.provider vmware do |v|
      v.vmx['memsize'] = $vm_memory
      v.vmx['numvcpus'] = $vm_cpus
    end
  end

  config.vm.provider :virtualbox do |vb|
    vb.memory = $vm_memory
    vb.cpus = $vm_cpus
    vb.gui = $vm_gui
    vb.linked_clone = true

    # Other system customisations
    vb.customize ["modifyvm", :id, "--hpet", "off"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--nestedpaging", "on"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--largepages", "on"]
    vb.customize ["modifyvm", :id, "--vtxvpid", "on"]
    vb.customize ["modifyvm", :id, "--vtxux", "on"]
    vb.customize ["modifyvm", :id, "--vram", "32"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--monitorcount", "1"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
  end

  config.vm.provider :hyperv do |hyperv|
    hyperv.maxmemory = $vm_memory
    hyperv.cpus = $vm_cpus
  end

  # Install required development packages
  config.vm.provision "packages", type: "shell" do |shell|
    shell.path = "provision-packages.sh"
  end

  # Install a Kubernetes distribution
  config.vm.provision "kubernetes", type: "shell" do |shell|
    shell.path = "provision-kubernetes.sh"
  end

end
