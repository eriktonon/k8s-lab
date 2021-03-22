#!/bin/bash

sudo cat >> /etc/haproxy/haproxy.cfg <<EOF
frontend kubernets
    mode tcp
    bind 192.168.99.106:6443
    option tcplog
    default_backend k8s-masters

backend k8s-masters
   mode tcp
   balance roundrobin
   option tcp-check
   server k8s-master-0 192.168.99.100:6443 check fall 3 rise 2
   server k8s-master-0 192.168.99.101:6443 check fall 3 rise 2
   server k8s-master-0 192.168.99.102:6443 check fall 3 rise 2
EOF
sudo systemctl restart haproxy