#!/bin/bash

#Настройка синхронизации времени
cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
systemctl restart chronyd

#Установка nginx
yum install -y epel-release
yum install -y nginx
systemctl start nginx
systemctl enable nginx

#Настройка отправки логов
cp /vagrant/config/web/nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx
cp /vagrant/config/web/audit.rules /etc/audit/rules.d/audit.rules
yum -y install audispd-plugins.x86_64
cp /vagrant/config/web/auditd.conf /etc/audit/auditd.conf
cp /vagrant/config/web/au-remote.conf /etc/audisp/plugins.d/au-remote.conf
cp /vagrant/config/web/audisp-remote.conf /etc/audisp/audisp-remote.conf
service auditd restart
