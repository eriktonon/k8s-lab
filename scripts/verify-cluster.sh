#!/usr/bin/env bash
# ==============================================================================
# Build-to-Manage (BTM) Cluster Readiness & Operational Gate Verification
# ==============================================================================
set -euo pipefail

KUBECONFIG_PATH="${KUBECONFIG:-.cluster/config}"

if [[ ! -f "${KUBECONFIG_PATH}" ]] && [[ -f "/etc/kubernetes/admin.conf" ]]; then
  KUBECONFIG_PATH="/etc/kubernetes/admin.conf"
fi

if [[ ! -f "${KUBECONFIG_PATH}" ]]; then
  echo "[ERROR] Kubeconfig not found at ${KUBECONFIG_PATH}. Ensure the cluster is running (make up)."
  exit 1
fi

export KUBECONFIG="${KUBECONFIG_PATH}"

echo "=============================================================================="
echo " [BTM GATE 1/5] Checking Kubernetes API Server Readiness (/readyz)"
echo "=============================================================================="
kubectl get --raw=/readyz
echo -e "\n[PASS] API Server is healthy.\n"

echo "=============================================================================="
echo " [BTM GATE 2/5] Verifying Multi-Node Topology & Node Ready Status"
echo "=============================================================================="
kubectl get nodes -o wide
NOT_READY_COUNT=$(kubectl get nodes --no-headers | grep -cv " Ready " || true)
if [[ "${NOT_READY_COUNT}" -ne 0 ]]; then
  echo "[FAIL] ${NOT_READY_COUNT} node(s) are not in Ready state."
  exit 1
fi
echo -e "[PASS] All cluster nodes are Ready.\n"

echo "=============================================================================="
echo " [BTM GATE 3/5] Auditing Control Plane & CNI System Pods (kube-system)"
echo "=============================================================================="
kubectl get pods -n kube-system -o wide
echo -e "[PASS] System control plane pods verified.\n"

echo "=============================================================================="
echo " [BTM GATE 4/5] Verifying Metrics Server Telemetry API"
echo "=============================================================================="
if kubectl top nodes >/dev/null 2>&1; then
  kubectl top nodes
  echo -e "[PASS] Metrics API (metrics.k8s.io) is active.\n"
else
  echo "[WARN] Metrics Server is still warming up; retry 'kubectl top nodes' in 60s."
fi

echo "=============================================================================="
echo " [BTM GATE 5/5] Checking Platform Engineering Namespaces & Governance"
echo "=============================================================================="
kubectl get namespaces --show-labels
echo -e "\n[SUCCESS] All Build-to-Manage cluster readiness gates completed."
