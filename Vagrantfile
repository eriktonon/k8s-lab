# -*- mode: ruby -*-
# vi: set ft=ruby :
# Variaveis
VAGRANTFILE_API_VERSION = 2
# Chamando modulo YAML
require 'yaml'

# Lendo o arquivo YAML com as configuracoes do ambiente
env = YAML.load_file('environment.yaml')

        if !(File.exists?('id_rsa'))
          system("ssh-keygen -b 2048 -t rsa -f id_rsa -q -N ''")
       end

# Limitando apenas a ultima versao estavel do Vagrant instalada
Vagrant.require_version '>= 2.0.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Iteracao com os servidores do ambiente
  env.each do |env|
    if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    end
    config.vm.define env['name'] do |srv|
      srv.vm.box      = env['box']
      srv.vm.hostname = env['hostname']
      srv.vm.network 'private_network', ip: env['ipaddress']
      srv.vm.provider 'virtualbox' do |vb|
        vb.name   = env['name']
        vb.gui    = false
        vb.memory = env['memory']
        vb.cpus   = env['cpus']
      end
      srv.vm.provision 'ansible_local' do |ansible|
        ansible.playbook           = env['provision']
        ansible.install_mode       = 'pip'
        ansible.become             = true
        ansible.become_user        = 'root'
        ansible.compatibility_mode = '2.0'
      end
      
      config.vm.provision "shell", inline: <<-SHELL
     sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
     systemctl restart sshd
     SHELL
      config.vm.provision "shell", inline: "mkdir -p /root/.ssh"
      config.vm.provision "shell", inline: "cp /vagrant/id_rsa /root/.ssh/id_rsa"
      config.vm.provision "shell", inline: "cp /vagrant/id_rsa.pub /root/.ssh/authorized_keys"
      config.vm.provision "shell", inline: "chmod 600 /root/.ssh/id_rsa"
      
    end
  end
end
