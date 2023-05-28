#!/bin/bash
yum update -y
yum clean all

echo 'vagrant ALL=(ALL) NOPASSWD:ALL' | /usr/bin/sudo EDITOR='tee -a' visudo
mkdir -pm 700 /home/vagrant/.ssh
curl -sL https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

echo 'UseDNS no' >> /etc/ssh/sshd_config


rm -rf /tmp/*
rm  -f /var/log/wtmp /var/log/btmp
rm -rf /var/cache/* /usr/share/doc/*
rm -rf /var/cache/yum
rm -rf /home/vagrant/*.iso
rm  -f ~/.bash_history
history -c

rm -rf /run/log/journal/*
sync
grub2-set-default 1
echo "###   Hi from second stage" >> /boot/grub2/grub.cfg
