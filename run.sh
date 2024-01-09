#!/bin/sh
virt-install \
  --connect qemu:///system \
  --name test-vm \
  --memory 4096 \
  --disk size=40 \
  --boot uefi \
  --graphics spice \
  --cdrom ./result/iso/nixos-24.05.20231204.2c7f3c0-x86_64-linux.iso
