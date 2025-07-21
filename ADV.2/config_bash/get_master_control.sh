#!/bin/bash
NAME="master_node1"

sudo su

kubeadm init --pod-network-cidr=10.17.0.0/16 --service-cidr=10.96.0.0/12 > /root/kubeinit.log

# control command for workers
cat /root/kubeinit.log | grep -A 1 "kubeadm join" > /root/join.sh
chmod +777 /root/join.sh

# move in home dir conf. setup
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# include worker ingress
sudo cp /etc/kubernetes/admin.conf /home/vagrant/admin.conf
sudo chmod 666 /home/vagrant/admin.conf

# No taint in master
kubectl wait --for=condition=ready node $NAME --timeout=120s
kubectl taint nodes $NAME node-role.kubernetes.io/control-plane-