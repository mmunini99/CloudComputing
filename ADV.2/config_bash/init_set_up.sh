#!/bin/bash



# Start to define the network
if [[ $(nmcli -t c show  | grep "Wired connection 2" | wc -l) -ne 0 ]]; then
nmcli c del "Wired connection 2";
fi
if [[ $(nmcli -t c show  | grep hpc | wc -l) -ne 0 ]]; then
nmcli c del "hpc-net";
fi

nmcli con add type ethernet \
    con-name net-config \
    ifname eth1 \
    ip4 $1/24 \
    gw4 10.10.0.1 \
    ipv4.method manual \
    autoconnect yes


nmcli con up hpc-net;

# generate the SSH key



# Define .ssh dir
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Generation
if [[ ! -f /root/.ssh/id_rsa ]]; then
    ssh-keygen -t rsa -b 4096 -N "" -f /root/.ssh/id_rsa
fi


cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub

# Also, in debug fixing I need to put also to the user
mkdir -p /home/vagrant/.ssh
cp /root/.ssh/id_rsa /home/vagrant/.ssh/id_rsa
cp /root/.ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/id_rsa
chmod 644 /home/vagrant/.ssh/id_rsa.pub

chmod 600 /root/.ssh/authorized_keys;

sudo su


# Kubernetes
modprobe overlay
modprobe br_netfilter
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF


cat <<EOF |  tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

# Debug fixing: try close zram
touch /etc/systemd/zram-generator.conf
swapoff -a


setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

cat << EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF



dnf install iproute-tc wget vim bash-completion bat crio podman docker helm -y
dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
dnf makecache

# get kubelet and docker
sed -i 's/10.85.0.0\/16/10.17.0.0\/16/' /etc/cni/net.d/100-crio-bridge.conflist
systemctl enable --now crio
systemctl enable --now kubelet
systemctl enable --now docker


sudo mkdir -p /opt/cni/bin
sudo curl -O -L https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
sudo tar -C /opt/cni/bin -xzf cni-plugins-linux-amd64-v1.2.0.tgz



cd ~
echo "export EDITOR=vim" >> /home/vagrant/.bashrc
echo "alias k=kubectl" >> /home/vagrant/.bashrc
echo "alias c=clear" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc