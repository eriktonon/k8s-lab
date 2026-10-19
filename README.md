# Kubernetes Multi-Node Cluster & Platform Engineering Lab (`k8s-lab`)

[![CI Validation](https://github.com/eriktonon/k8s-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/eriktonon/k8s-lab/actions/workflows/ci.yml)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.31_(pkgs.k8s.io)-%23326CE5?style=flat-square&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Runtime](https://img.shields.io/badge/CRI_Runtime-containerd_(SystemdCgroup)-%2357B2E6?style=flat-square&logo=containerd&logoColor=white)](https://containerd.io/)
[![Ansible](https://img.shields.io/badge/Automation-Ansible_Roles-%23EE0000?style=flat-square&logo=ansible&logoColor=white)](provision/ansible/)
[![Vagrant](https://img.shields.io/badge/OS-Ubuntu_24.04_LTS-%23E95420?style=flat-square&logo=ubuntu&logoColor=white)](environment.yaml)

Automated, zero-touch multi-node **Kubernetes (`kubeadm` v1.31)** cluster lab provisioned with **Vagrant** and modular **Ansible roles**, pre-configured with **containerd CRI v1**, **IPVS `kube-proxy`**, **Calico CNI**, **Metrics Server**, and **Build-to-Manage (BTM)** platform governance manifests.

---

## 1. Architecture & Cluster Topology

```mermaid
flowchart TB
    subgraph Host["Host Workstation (Vagrant 2.3+ · VirtualBox / Libvirt)"]
        VF["Vagrantfile + environment.yaml<br/>Private Network: 192.168.99.0/24"]
        CL[".cluster/<br/>kubeconfig · join-command.sh · id_ed25519"]
    end

    subgraph Ansible["Idempotent Ansible Roles (provision/ansible/roles/)"]
        R1["common<br/>Swapoff · Kernel Modules (overlay, br_netfilter, ip_vs) · Sysctl · Chrony"]
        R2["containerd<br/>CRI v1 · SystemdCgroup=true · crictl"]
        R3["kubernetes<br/>pkgs.k8s.io v1.31 Keyring · kubeadm / kubelet / kubectl · Version Hold"]
        R4["control_plane<br/>KubeadmConfig v1beta4 · IPVS · Calico CNI · Metrics Server"]
        R5["worker<br/>Zero-Touch kubeadm join · Node Role Labeling"]
    end

    subgraph Cluster["Kubernetes v1.31 Cluster (Ubuntu 24.04 LTS)"]
        CP["master.k8s.corp.br (192.168.99.100)<br/>Control Plane · 4 GB RAM · 2 vCPUs"]
        W1["node1.k8s.corp.br (192.168.99.101)<br/>Worker Node 1 · 2 GB RAM · 2 vCPUs"]
        W2["node2.k8s.corp.br (192.168.99.102)<br/>Worker Node 2 · 2 GB RAM · 2 vCPUs"]
    end

    subgraph Platform["Build-to-Manage (BTM) Governance Layer (manifests/platform/)"]
        PSS["Pod Security Standards (Restricted / Baseline)"]
        RQ["ResourceQuotas & LimitRanges"]
        NP["Zero-Trust NetworkPolicies"]
        MLB["MetalLB L2 VIP Pool (192.168.99.200–250)"]
        REF["Reference Golden Workload (Probes · PDB · HPA · Non-Root)"]
    end

    VF --> Ansible
    R1 --> R2 --> R3
    R3 --> R4 & R5
    R4 --> CP
    R4 -.->|"Exports admin.conf & join token"| CL
    CL -.->|"Automated Join"| R5
    R5 --> W1 & W2
    CP --> Platform
```

### Node Specification (`environment.yaml`)

| Node | Role | FQDN | IP Address | vCPUs | RAM | Base Box |
|---|---|---|---|---|---|---|
| `master` | Control Plane | `master.k8s.corp.br` | `192.168.99.100` | 2 | 4096 MB | `bento/ubuntu-24.04` |
| `node1` | Worker Node | `node1.k8s.corp.br` | `192.168.99.101` | 2 | 2048 MB | `bento/ubuntu-24.04` |
| `node2` | Worker Node | `node2.k8s.corp.br` | `192.168.99.102` | 2 | 2048 MB | `bento/ubuntu-24.04` |

---

## 2. Technical Stack & Platform Engineering Decisions

- **CRI Runtime (`containerd`)**: Replaces legacy `dockershim` with native `containerd.io` configured with `SystemdCgroup = true` and `registry.k8s.io/pause:3.10`, aligned with kubelet's `systemd` cgroup driver.
- **Official CNCF Package Repositories (`pkgs.k8s.io`)**: Uses signed GPG keyrings (`/etc/apt/keyrings/kubernetes-apt-keyring.gpg`) for Kubernetes `v1.31` packages with `dpkg_selections: hold` to prevent unplanned drift during OS patching.
- **IPVS Service Proxying**: Loads kernel IPVS scheduling modules (`ip_vs`, `ip_vs_rr`, `ip_vs_wrr`, `ip_vs_sh`, `nf_conntrack`) and configures `KubeProxyConfiguration` in `ipvs` mode for deterministic $O(1)$ service routing.
- **Zero-Touch Worker Auto-Join**: The `control_plane` Ansible role exports the cluster `admin.conf` and a signed join script to `.cluster/` (gitignored), allowing `node1` and `node2` to join the cluster automatically during `vagrant up` without manual token copy-pasting.
- **Build-to-Manage (BTM) Golden Manifests**: Ships production-grade Kubernetes manifests in `manifests/platform/` enforcing Pod Security Standards (`restricted`), `ResourceQuota`, `LimitRange`, default-deny `NetworkPolicy`, `PodDisruptionBudget`, and `HorizontalPodAutoscaler`.

---

## 3. Repository Structure

```text
.
├── .github/workflows/ci.yml                  # Automated syntax & lint validation (Ruby, YAML, Ansible, ShellCheck)
├── Vagrantfile                               # Multi-provider (VirtualBox / Libvirt) declarative Vagrantfile
├── environment.yaml                          # Node topology, resource allocation, and network matrix
├── Makefile                                  # Developer Experience (DX) & Day-2 operational commands
├── startLab.sh                               # Zero-touch cluster bootstrap script
├── scripts/
│   └── verify-cluster.sh                     # 5-stage Build-to-Manage readiness verification gate
├── manifests/platform/
│   ├── 00-namespaces.yaml                    # Platform, Observability & Workloads namespaces with PSS labels
│   ├── 01-governance-quotas.yaml             # FinOps ResourceQuota & LimitRange guardrails
│   ├── 02-network-policies.yaml              # Zero-Trust default-deny ingress & DNS/namespace allowlist
│   ├── 03-metallb-l2.yaml                    # Bare-metal LoadBalancer L2 VIP pool (192.168.99.200-250)
│   └── 04-reference-workload.yaml            # Hardened non-root reference service (Probes, PDB, HPA)
└── provision/ansible/
    ├── ansible.cfg                           # Ansible runner configuration
    ├── site.yml                              # Unified cluster playbook
    ├── master.yaml                           # Control-plane entrypoint
    ├── nodes.yaml                            # Worker-node entrypoint
    ├── group_vars/all.yml                    # Version pins, CIDRs, kernel modules, and sysctl settings
    ├── inventory/hosts.yml                   # Static inventory for standalone Ansible execution
    └── roles/
        ├── common/                           # Swap disable, kernel modules, sysctl, chrony, /etc/hosts
        ├── containerd/                       # containerd.io CRI v1, SystemdCgroup=true, crictl
        ├── kubernetes/                       # pkgs.k8s.io GPG keyring, kubeadm/kubelet/kubectl
        ├── control_plane/                    # kubeadm init, Calico CNI, Metrics Server, token export
        └── worker/                           # Automated kubeadm join & worker node labeling
```

---

## 4. Quick Start (Zero-Touch Provisioning)

### Prerequisites
- [Vagrant](https://www.vagrantup.com/) `>= 2.3`
- [VirtualBox](https://www.virtualbox.org/) `>= 7.0` (or `vagrant-libvirt` for KVM)
- `kubectl` (optional on host; pre-installed inside all cluster nodes)

### 1. Bootstrap the Cluster

```bash
git clone https://github.com/eriktonon/k8s-lab.git
cd k8s-lab
make up
```

During `make up` (or `./startLab.sh`):
1. An internal Ed25519 SSH keypair is generated in `.cluster/id_ed25519`.
2. `master` initializes the Kubernetes `v1.31` control plane, installs **Calico CNI** + **Metrics Server**, and exports `.cluster/config` and `.cluster/join-command.sh`.
3. `node1` and `node2` automatically join the cluster and receive the `node-role.kubernetes.io/worker=worker` label.

### 2. Access the Cluster from Your Host

```bash
export KUBECONFIG="$(pwd)/.cluster/config"
kubectl get nodes -o wide
```

Or SSH directly into the control plane:

```bash
vagrant ssh master
kubectl get nodes -o wide
```

### 3. Apply Build-to-Manage Platform Governance & Verify Readiness

```bash
make apply-platform
make verify
```

---

## 5. Day-2 Operations & Runbook Commands

| Command | Action |
|---|---|
| `make up` | Provision VMs, bootstrap Kubernetes control plane, and auto-join workers |
| `make status` | Check Vagrant VM state and `kubectl get nodes -o wide` |
| `make verify` | Run the 5-stage Build-to-Manage readiness gate (`scripts/verify-cluster.sh`) |
| `make apply-platform` | Apply PSS namespaces, ResourceQuotas, NetworkPolicies, and reference workload |
| `make lint` | Run syntax checks on `Vagrantfile`, Ansible roles, and YAML manifests |
| `make halt` | Gracefully stop cluster VMs while preserving etcd state |
| `make destroy` | Tear down all VMs and purge `.cluster/` credentials |

---

## Author

**Erik Tonon** — *Head of Platform Engineering & Generative AI @ IBM Consulting | Ex-Associate Director at BTG Pactual | Founder @ EdgeSearch Labs*
- Website: [eriktonon.com](https://eriktonon.com)
- LinkedIn: [linkedin.com/in/erik-tonon](https://www.linkedin.com/in/erik-tonon/)
