# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "centos/7"
  config.vm.box_version = "1710.01"

  config.vm.define :centos7 do |centos7|
    centos7.vm.provider "virtualbox" do |v|
      v.linked_clone = true
    end

    centos7.vm.hostname = 'centos7'

    centos7.vm.network "private_network", ip: "192.168.1.101"

    centos7.vm.provision "ssh:root", type: :shell do |s|
      private_key = "/vagrant/.vagrant/machines/#{centos7.vm.hostname}/virtualbox/private_key"
      s.inline = <<-SHELL
        sudo su - root -c "mkdir -p /root/.ssh/"
        sudo chmod 700 /root/.ssh/
        ssh-keygen -yf #{private_key} > /root/.ssh/authorized_keys
        sudo chmod 600 /root/.ssh/authorized_keys
      SHELL
    end
  end

  config.vm.provision "selinux:disabled", type: :shell do |s|
    s.inline = "sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config"
  end

  config.vm.provision "sshd:PasswordAuthentication:yes", type: :shell do |s|
    s.inline = "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
  end

  config.vm.provision "timedatectl:set-timezone:Asia/Tokyo", type: :shell do |s|
    s.inline = "timedatectl set-timezone Asia/Tokyo"
  end

  config.vm.provision "yum:install:tmux", type: :shell do |s|
    s.inline = "yum install tmux -y"
  end

  config.vm.provision "yum:install:vim", type: :shell do |s|
    s.inline = "yum install vim-enhanced -y"
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    puts "-- has_plugin: vagrant-vbguest"
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  end

  if Vagrant.has_plugin?("vagrant-proxyconf")
    puts "-- has_plugin: vagrant-proxyconf"
    puts "   http_proxy  is [#{ENV["http_proxy"]}]"
    puts "   https_proxy is [#{ENV["https_proxy"]}]"
    puts "   no_proxy    is [#{ENV["no_proxy"]}]"
    config.proxy.http     = ENV["http_proxy"]
    config.proxy.https    = ENV["https_proxy"]
    config.proxy.no_proxy = ENV["no_proxy"]
  end
end
