#!/usr/bin/env bash
# ==============================================================================
# Zero-Touch Multi-Node Kubernetes Lab Bootstrap
# ==============================================================================
set -euo pipefail

mkdir -p .cluster

if [[ ! -f ".cluster/id_ed25519" ]]; then
  echo "[INFO] Generating internal cluster Ed25519 SSH keypair in .cluster/id_ed25519..."
  ssh-keygen -t ed25519 -f .cluster/id_ed25519 -q -N "" -C "k8s-lab-internal"
fi

echo "[INFO] Provisioning multi-node Kubernetes cluster via Vagrant + Ansible..."
vagrant up

echo "[INFO] Cluster bootstrap complete. Exporting KUBECONFIG=$(pwd)/.cluster/config"
if [[ -f ".cluster/config" ]]; then
  export KUBECONFIG="$(pwd)/.cluster/config"
  ./scripts/verify-cluster.sh
fi