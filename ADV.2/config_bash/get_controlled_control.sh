#!/bin/bash
IP=10.10.0.80
export IP


sudo su

scp -o stricthostkeychecking=no root@$IP:/home/vagrant/admin.conf /home/vagrant/admin.conf

# move in home dir conf. setup
mkdir -p $HOME/.kube
sudo cp -i /home/vagrant/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


scp -o StrictHostKeyChecking=no root@$IP:/root/join.sh /root/join.sh
/root/join.sh