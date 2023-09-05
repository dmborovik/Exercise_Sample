#!/bin/bash

#Настройка синхронизации времени
cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
systemctl restart chronyd

#Настройка сбора логов
cp /vagrant/config/log/rsyslog.conf /etc/rsyslog.conf #Переносим, конфиг с вненсенными изменениями. 
systemctl restart rsyslog
cp /vagrant/config/log/auditd.conf /etc/audit/auditd.conf
service auditd restart