# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

require "yaml"
require "fileutils"

Vagrant.require_version ">= 2.3.0"

CLUSTER_DIR = File.join(__dir__, ".cluster")
SSH_KEY_PATH = File.join(CLUSTER_DIR, "id_ed25519")

FileUtils.mkdir_p(CLUSTER_DIR)

unless File.exist?(SSH_KEY_PATH)
  system("ssh-keygen -t ed25519 -f \"#{SSH_KEY_PATH}\" -q -N \"\" -C \"k8s-lab-internal\"")
end

nodes = YAML.safe_load_file(File.join(__dir__, "environment.yaml"))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  nodes.each do |node|
    config.vm.define node["name"] do |srv|
      srv.vm.box      = ENV.fetch("K8S_LAB_BOX", node["box"])
      srv.vm.hostname = node["hostname"]
      srv.vm.network "private_network", ip: node["ipaddress"]

      srv.vm.provider "virtualbox" do |vb|
        vb.name   = "k8s-lab-#{node['name']}"
        vb.gui    = false
        vb.memory = node["memory"]
        vb.cpus   = node["cpus"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end

      srv.vm.provider "libvirt" do |lv|
        lv.memory = node["memory"]
        lv.cpus   = node["cpus"]
      end

      srv.vm.provision "shell", inline: <<-SHELL
        set -euo pipefail
        mkdir -p /root/.ssh /home/vagrant/.ssh
        if [ -f /vagrant/.cluster/id_ed25519 ]; then
          cp /vagrant/.cluster/id_ed25519 /root/.ssh/id_ed25519
          cp /vagrant/.cluster/id_ed25519.pub /root/.ssh/id_ed25519.pub
          cat /vagrant/.cluster/id_ed25519.pub >> /root/.ssh/authorized_keys
          cat /vagrant/.cluster/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys
          chmod 600 /root/.ssh/id_ed25519 /root/.ssh/authorized_keys /home/vagrant/.ssh/authorized_keys
          chown -R vagrant:vagrant /home/vagrant/.ssh
        fi
      SHELL

      srv.vm.provision "ansible_local" do |ansible|
        ansible.provisioning_path = "/vagrant/provision/ansible"
        ansible.playbook          = File.basename(node["provision"])
        ansible.config_file       = "/vagrant/provision/ansible/ansible.cfg"
        ansible.install_mode      = "default"
        ansible.become            = true
        ansible.become_user       = "root"
        ansible.extra_vars        = {
          node_name: node["name"],
          node_role: node["role"],
          node_ip:   node["ipaddress"],
          node_fqdn: node["hostname"]
        }
      end
    end
  end
end
