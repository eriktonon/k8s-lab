# Kubernetes Cluster Provisioning & Platform Engineering Lab

[![Kubernetes](https://img.shields.io/badge/Kubernetes-Multi--Node_Cluster-%23326CE5?style=flat-square&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Ansible](https://img.shields.io/badge/Provisioning-Ansible_Playbooks-%23EE0000?style=flat-square&logo=ansible&logoColor=white)](provision/ansible/)
[![Vagrant](https://img.shields.io/badge/Infrastructure-Vagrant_%2B_VirtualBox-%231868F2?style=flat-square&logo=vagrant&logoColor=white)](Vagrantfile)

Automated local multi-node **Kubernetes (`kubeadm`)** cluster lab provisioned with **Vagrant** and **Ansible** for testing CNI networking, control-plane bootstrap, and platform engineering workloads.

---

## Architecture & Topology

- **Control Plane (`master`)**: Initialized via `kubeadm` with automated container runtime, kernel module tuning (`overlay`, `br_netfilter`), and sysctl forwarding rules applied via Ansible.
- **Worker Nodes (`node1`, `node2`)**: Provisioned automatically with matching container runtime and Kubernetes packages (`kubelet`, `kubeadm`, `kubectl`), ready for cluster join.

---

## Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) + Extension Pack
- [Ansible](https://docs.ansible.com/)

---

## Quick Start

### 1. Clone and Bootstrap the Environment

```bash
git clone https://github.com/eriktonon/k8s-lab.git
cd k8s-lab
chmod +x startLab.sh
./startLab.sh
```

### 2. Retrieve Join Token from Control Plane

```bash
vagrant ssh master
sudo kubeadm token create --print-join-command
```

### 3. Join Worker Nodes to the Cluster

```bash
vagrant ssh node1 -c "sudo kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
vagrant ssh node2 -c "sudo kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>"
```

---

## Author

**Erik Tonon** — *Head of Platform Engineering & Generative AI @ IBM Consulting | Ex-Associate Director at BTG Pactual | Founder @ EdgeSearch Labs*
- Website: [eriktonon.com](https://eriktonon.com)
- LinkedIn: [linkedin.com/in/erik-tonon](https://www.linkedin.com/in/erik-tonon/)
