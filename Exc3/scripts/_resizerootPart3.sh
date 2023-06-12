#!/bin/bash

lvremove /dev/VolGroup00/LogVol00 -y
lvcreate -n LogVol00 -L8G /dev/VolGroup00 -y
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt