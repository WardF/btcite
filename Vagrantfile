# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.ssh.forward_x11 = "true"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 1
  end

  config.vm.provider "parallels" do |v|
    v.memory = 2048
    v.cpus = 1
  end

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.define "webserver",primary: true do |v|
    v.vm.provision :shell, :path => "bootstrap_dev.sh"
    v.vm.network "private_network", ip: "10.1.2.11"
    v.vm.box = "WardF/trusty64"
  end

 config.vm.define "plain" do |v|
    v.vm.box = "WardF/trusty64"
  end

end
