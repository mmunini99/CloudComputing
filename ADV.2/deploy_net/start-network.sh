#!/bin/bash


sudo virsh net-define net-config-structure.xml 
sudo virsh net-start net-config 
sudo virsh net-autostart net-config 

echo "Network status: OK"

