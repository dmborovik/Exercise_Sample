#!/bin/bash

grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;  s/.img//g"` --force; done
sed -i "s|rd.lvm.lv=VolGroup00/LogVol00|rd.lvm.lv=vg_root/lv_root|g" /boot/grub2/grub.cfg
