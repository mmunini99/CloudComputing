#!/bin/bash


sudo virsh net-destroy net-config 
sudo virsh net-undefine net-config 

echo "Network down"
