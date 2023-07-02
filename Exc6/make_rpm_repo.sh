#!/bin/bash
#Создание своего rpm пакета (nginx с поддержкой openssl 1.1)

# Устанавливаем, необходимые пакеты для сборки
yum install -y wget rpm-build createrepo

#Скачиваем пакет nginx и исходник openssl
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.24.0-1.el7.ngx.src.rpm
wget https://www.openssl.org/source/openssl-1.1.1u.tar.gz --no-check-certificate

#создадим струтуру каталогов и перенесем туда наш архив с openssl 
rpm -i nginx-1.24.0-1.el7.ngx.src.rpm 
mv openssl-1.1.1u.tar.gz ~/rpmbuild/

#распакуем наш архив и добавим строку в SPEC для поддержки openssl 
cd ~/rpmbuild
tar -xf openssl-1.1.1u.tar.gz 
rm openssl-1.1.1u.tar.gz 
sed -i 's/--with-debug/--with-openssl=\/root\/rpmbuild\/openssl-1.1.1u/g' SPECS/nginx.spec 

#поставим все зависимости
yum-builddep -y SPECS/nginx.spec
#Собираем пакет
rpmbuild -bb SPECS/nginx.spec

yum -y localinstall RPMS/x86_64/nginx-1.24.0-1.el7.ngx.x86_64.rpm 
systemctl enable nginx --now

# Создание репо

#Создадим репу доступной через nginx, очистим рабочий каталог и создадим для реп
rm -rf /usr/share/nginx/html/*
mkdir /usr/share/nginx/html/repo

#Копируем наш пакет в него и туда же качаем еще какой-нибудь пакет, например tmux. 
cp RPMS/x86_64/nginx-1.24.0-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget https://rpmfind.net/linux/centos/7.9.2009/os/x86_64/Packages/tmux-1.8-4.el7.x86_64.rpm -O /usr/share/nginx/html/repo/tmux-1.8-4.el7.x86_64.rpm

#Создаем репозиторий
createrepo /usr/share/nginx/html/repo/
createrepo --update /usr/share/nginx/html/repo/

#Добавляем директиву autoindex on в конфиг nginx
sed -i '/index  index.html index.htm;/s/$/ \n\tautoindex on;/' /etc/nginx/conf.d/default.conf

#Перезагружаем nginx
nginx -s reload

#Добавляем созданный репозиторий в системный 
cat >> /etc/yum.repos.d/myrepo.repo << EOF
[myrepo]
name=myrepo
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
yum clean all

echo 'Profit!!!'