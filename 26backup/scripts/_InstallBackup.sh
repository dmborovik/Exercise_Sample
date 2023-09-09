#!/bin/bash

#Подключаем EPEL и устанавливаем borgbackup
yum install epel-release -y
yum install borgbackup -y 


#Создаем каталог для backup
mkdir /var/backup
useradd borg


#Выносим на отдельный диск 
yes|mkfs.ext4 /dev/sdb
mount /dev/sdb /var/backup/
chown borg:borg /var/backup/




