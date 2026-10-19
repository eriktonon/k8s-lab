.PHONY: help up halt destroy status verify apply-platform kubeconfig lint

KUBECONFIG_FILE := $(CURDIR)/.cluster/config

help: ## Display available Platform Engineering & Lab commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Bootstrap full multi-node Kubernetes cluster (Control Plane + 2 Workers)
	@chmod +x startLab.sh scripts/verify-cluster.sh
	@./startLab.sh

status: ## Check Vagrant VM status and Kubernetes nodes
	@vagrant status
	@if [ -f "$(KUBECONFIG_FILE)" ]; then KUBECONFIG="$(KUBECONFIG_FILE)" kubectl get nodes -o wide; fi

verify: ## Run deterministic Build-to-Manage (BTM) cluster readiness checks
	@chmod +x scripts/verify-cluster.sh
	@KUBECONFIG="$(KUBECONFIG_FILE)" ./scripts/verify-cluster.sh

apply-platform: ## Deploy Platform Engineering governance (Namespaces, Quotas, NetworkPolicies, Reference App)
	@KUBECONFIG="$(KUBECONFIG_FILE)" kubectl apply -f manifests/platform/00-namespaces.yaml
	@KUBECONFIG="$(KUBECONFIG_FILE)" kubectl apply -f manifests/platform/01-governance-quotas.yaml
	@KUBECONFIG="$(KUBECONFIG_FILE)" kubectl apply -f manifests/platform/02-network-policies.yaml
	@KUBECONFIG="$(KUBECONFIG_FILE)" kubectl apply -f manifests/platform/04-reference-workload.yaml

kubeconfig: ## Print export command to bind host kubectl to cluster
	@echo "export KUBECONFIG=$(KUBECONFIG_FILE)"

lint: ## Validate Ruby Vagrantfile, Ansible Playbooks, YAML, and Shell scripts
	@ruby -c Vagrantfile
	@ANSIBLE_ROLES_PATH=provision/ansible/roles ansible-playbook --syntax-check -i provision/ansible/inventory/hosts.yml provision/ansible/site.yml
	@ANSIBLE_ROLES_PATH=provision/ansible/roles ansible-playbook --syntax-check -i provision/ansible/inventory/hosts.yml provision/ansible/master.yaml
	@ANSIBLE_ROLES_PATH=provision/ansible/roles ansible-playbook --syntax-check -i provision/ansible/inventory/hosts.yml provision/ansible/nodes.yaml

halt: ## Gracefully suspend all cluster virtual machines
	@vagrant halt

destroy: ## Destroy all virtual machines and clean up .cluster/ state
	@vagrant destroy -f
	@rm -rf .cluster
