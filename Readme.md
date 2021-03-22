# K8s experimental version of instant laboratory of kubernetes

## This repository will always be getting improvements

## Requirements
- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads) 
- [Virtualbox extension pack](https://www.virtualbox.org/wiki/Downloads) 

## Installation Linux
### open your terminal and execute the commands below (First run only)
 
  ```bash
  $ git clone https://github.com/eriktonon/k8s-lab.git
  $ cd k8s-lab
  $ chmod +x startLab.sh
  $ bash startLab.sh
  $ vagrant ssh master 
  ## use sudo or sudo su to perform the commands below
  $ kubeadm token create --print-join-command
  ## copy the return and paste in the nodes
  $ vagrant ssh node1 paste kubeadm join \ <control-plane-host>:<control-plane-port> \ --token <token> \ --discovery-token-ca-cert-hash sha256:<hash>
  $ vagrant ssh node2 paste kubeadm join \ <control-plane-host>:<control-plane-port> \ --token <token> \ --discovery-token-ca-cert-hash sha256:<hash>
  ```
