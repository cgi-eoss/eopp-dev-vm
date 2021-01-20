#!/usr/bin/env bash

set -eux

snap install microk8s --classic

# Grant microk8s control to the normal vagrant user
usermod -a -G microk8s vagrant

# Configure microk8s behind a proxy, if necessary
if [ ! -z $HTTP_PROXY ] && ! grep -q '^HTTPS_PROXY' /var/snap/microk8s/current/args/containerd-env ; then
    cluster_cidr="$(grep 'cluster-cidr' /var/snap/microk8s/current/args/kube-proxy)"
    services_cidr="$(grep 'service-cluster-ip-range' /var/snap/microk8s/current/args/kube-apiserver)"
    containerd_no_proxy="${cluster_cidr#--cluster-cidr=},${services_cidr#--service-cluster-ip-range=}"
    echo -e "HTTPS_PROXY=$HTTPS_PROXY\nNO_PROXY=$containerd_no_proxy" | tee -a /var/snap/microk8s/current/args/containerd-env
    
    microk8s.stop
    microk8s.start
fi

# Wait 5 minutes for things to settle down
microk8s.status --wait-ready --timeout 300

# Enable basic cluster functionality
for addon in rbac storage registry ingress dns helm3; do
    if [ "$(microk8s.status --addon ${addon})" != "enabled" ]; then
        microk8s.enable "$addon"
    fi
done

# Configure DNS in the VM environment, not using the default public servers
default_interface=$(ip route | grep '^default' | tail -1 | grep -Po '(?<=dev )(\S+)')
if resolvectl status 2>/dev/null ; then
    dns_servers=$(resolvectl dns $default_interface | awk -F': ' '{print $2}')
else
    dns_servers=$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}')
fi
if ! microk8s.kubectl -n kube-system get configmap coredns -o yaml | grep -q "forward . ${dns_servers}" ; then
    microk8s.kubectl -n kube-system get configmap coredns -o yaml | sed "s/\bforward \. [^\\\]*\\\n/forward . ${dns_servers}\\\n/" | microk8s.kubectl apply -f -
fi

# Set up the `kubectl` and `helm` wrapper functions for users
echo "" >>/root/.bashrc
echo -e "kubectl() {\n  microk8s.kubectl \"\$@\"\n}" >>/root/.bashrc
echo "export -f kubectl" >>/root/.bashrc
echo -e "helm() {\n  microk8s.helm3 \"\$@\"\n}" >>/root/.bashrc
echo "export -f helm" >>/root/.bashrc
echo "" >>/root/.bashrc

echo "" >>/home/vagrant/.bashrc
echo -e "kubectl() {\n  microk8s.kubectl \"\$@\"\n}" >>/home/vagrant/.bashrc
echo "export -f kubectl" >>/home/vagrant/.bashrc
echo -e "helm() {\n  microk8s.helm3 \"\$@\"\n}" >>/home/vagrant/.bashrc
echo "export -f helm" >>/home/vagrant/.bashrc
echo "" >>/home/vagrant/.bashrc
