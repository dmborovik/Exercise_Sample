#!/bin/bash

# Создаем PV
pvcreate /dev/sdc /dev/sdd

# Создаем VG
vgcreate vg_var /dev/sdc /dev/sdd

# Создаем LV в mirror 
lvcreate -n lv_var -L950M -m1 vg_var

#Создаем ФС
mkfs.xfs /dev/mapper/vg_var-lv_var

#Создаем временную директорию и монтируем ее к нашей LV
mkdir /tmp/var
mount /dev/mapper/vg_var-lv_var /tmp/var

#Копируем данные 
cd /var && cp -dpRx * /tmp/var

#Отмонтируем временную директорию, добавим запись в fstab, примонтируем все. 
umount /tmp/var
echo "/dev/mapper/vg_var-lv_var /var xfs defaults 0 0" >> /etc/fstab
mount -a

echo "/var выделен в отдельный том"