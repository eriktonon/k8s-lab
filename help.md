# vim /etc/modules-load.d/k8s.conf
br_netfilter
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
ip_vs


# apt-get update -y && apt-get upgrade -y

# curl -fsSL https://get.docker.com | bash

# apt-get update && apt-get install -y apt-transport-https

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

# apt-get update

# apt-get install -y kubelet kubeadm kubectl

# swapoff -a

# vim /etc/fstab

# kubeadm config images pull

# kubeadm init

# mkdir -p $HOME/.kube

# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# kubectl get pods -n kube-system

# kubeadm join --token 39c341.a3bc3c4dd49758d5 IP_DO_MASTER:6443 --discovery-token-ca-cert-hash sha256:37092 

# kubectl get nodes

# kubectl describe node elliot-03

# kubeadm token create --print-join-command

# echo "source <(kubectl completion bash)" >> ~/.bashrc

# kubectl get namespace

# kubectl get pods -n kube-system

# kubectl get pods --all-namespaces

# kubectl run nginx --image nginx

# kubectl get deployments

# kubectl describe deployment nginx

# kubectl get events

# kubectl get deployment nginx -o yaml

# kubectl get deployment nginx -o yaml > meu_primeiro.yaml

# kubectl delete deployment nginx

# kubectl create -f meu_primeiro.yaml

# kubectl delete -f meu_primeiro.yaml

# kubectl get deploy,pod

# kubectl expose deployment/nginx

# kubectl get svc nginx 

# kubectl describe pod nginx-6f858d4d45-qxjlh

# kubectl get pods -o wide

# kubectl delete pods nginx-6f858d4d45-qxjlh
