#!/bin/bash


#Устанавливаем xfsdump
yum install xfsdump -y

#Готовим том для переноса рутового раздела
pvcreate /dev/sdb                       #Создаем том
vgcreate vg_root /dev/sdb               #Создаем VG
lvcreate -n lv_root -l100%FREE vg_root  #Создаем LV
mkfs.xfs /dev/vg_root/lv_root           #Создаем ФС

#Монтируем директорию, куда перенесем рутовый раздел 
mount /dev/vg_root/lv_root /mnt       

#Переносим рутовый раздел
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt 

#Делаем chroot в новый раздел и подменяем root на скопированные данные
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
