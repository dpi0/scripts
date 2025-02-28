#!/usr/bin/env bash

BASE_VM="archlinux-base-fresh"
NEW_VM="archlinux-new"
VM_DIR=$HOME/Virtual_Machines

cp "${VM_DIR}/${BASE_VM}.qcow2" "${VM_DIR}/${NEW_VM}.qcow2"
sudo chown libvirt-qemu:kvm "${VM_DIR}/${NEW_VM}.qcow2"
sudo chmod 660 "${VM_DIR}/${NEW_VM}.qcow2"

virsh dumpxml ${BASE_VM} > "${VM_DIR}/${NEW_VM}.xml"

# replace uuid with a newly generated one
NEW_UUID=$(uuidgen)
sed -i "s|<uuid>.*</uuid>|<uuid>${NEW_UUID}</uuid>|" "${VM_DIR}/${NEW_VM}.xml"

# change every instance of 'archlinux-base-fresh' to 'archlinux-new'
sed -i "s|${BASE_VM}|${NEW_VM}|g" "${VM_DIR}/${NEW_VM}.xml"

virsh define "${VM_DIR}/${NEW_VM}.xml"
virsh list --all

virsh start ${NEW_VM}
virt-manager --connect qemu:///system --show-domain-console ${VM_NAME}
