#!/bin/bash

#Создаем LV для home
lvcreate -n LogVol_Home -L2G VolGroup00

#Создаем ФС на созданном томе.
mkfs.xfs /dev/mapper/VolGroup00-LogVol_Home

#Создаем временную директорию для переноса данных
mkdir /tmp/home

#Монтируем созданную директорию в новый том 
mount /dev/mapper/VolGroup00-LogVol_Home /tmp/home/

#Копируем данные 
cd /home/ && cp -dpRx * /tmp/home/

#Отмонтируем временную директорию 
umount /tmp/home/

#Добавляем запись в fstab, чтобы после перезагруки раздел смонтировался. 
echo "/dev/mapper/VolGroup00-LogVol_Home /home xfs defaults 0 0">>/etc/fstab

#Монтируем все 
mount -a