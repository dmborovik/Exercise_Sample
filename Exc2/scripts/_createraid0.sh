!#/bin/bash

#Зануляем суперблок, на всякий. 
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e}

#Создаем RAID 0 из 4 дисков.
mdadm --create --verbose /dev/md0 -l 0 -n 4 /dev/sd{b..e}

#Создаем директорию для mdadm.conf и сам конфиг
mkdir /etc/mdadm
echo "DEVICE partitions">/etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose|awk '/ARRAY/{print}' >> /etc/mdadm/mdadm.conf

#Создаем ФС на нашем raid
mkfs.xfs /dev/md0

#Примонтируем и запишем что-нибудт в наш RAID, 

mkdir /test
mount /dev/md0 /test
    cp /var/log/messages /test

#Все, у нас есть RAID0 с копией лога messages. 

echo 'Массив с данными создан!'