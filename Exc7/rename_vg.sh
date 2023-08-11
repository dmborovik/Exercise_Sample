#! /bin/bash
#Переименовываем VG
vgrename VolGroup00 vg_root
#Правим /etc/fstab, /etc/default/grub и /boot/grub2/grub.cfg
sed -i "s|VolGroup00|vg_root|g" /etc/fstab /etc/default/grub /boot/grub2/grub.cfg
#Пересоздаем initrd image
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
echo 'Profit!'

#--------------###------------###-----------###---------------###

#Добавление модуля в initrd
mkdir -p /usr/lib/dracut/modules.d/01test/

cp /vagrant/*.sh /usr/lib/dracut/modules.d/01test/
chmod +x /usr/lib/dracut/modules.d/01test/*
dracut -f -v
sed -i "s|rhgb quiet||g" /boot/grub2/grub.cfg
grub2-mkconfig -o /etc/grub.cfg