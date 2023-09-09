#!/bin/bash

#Подключаем EPEL и устанавливаем borgbackup
yum install epel-release -y
yum install borgbackup -y 

useradd -m borg
