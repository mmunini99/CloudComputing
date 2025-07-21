#!/bin/bash
sudo su

cat << EOF | tee /etc/containers/registries.conf
[registries.search]
registries = ['docker.io']
EOF

# get tool for benchmarking in OSU
cd /home/vagrant/docker
podman build -f openmpi-builder.Dockerfile -t my-builder
podman build -f osu-code-provider.Dockerfile -t osu-code-provider
podman build -f openmpi.Dockerfile -t my-operator
podman build -t my-osu-bench .
chown -R vagrant:vagrant /home/vagrant/docker