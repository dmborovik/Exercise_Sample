#!/bin/bash

#Установка Prometheus
yum install wget -y
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
tar -xvzf prometheus-2.45.0.linux-amd64.tar.gz
mv prometheus-2.45.0.linux-amd64 prometheuspackage
cp prometheuspackage/prometheus /usr/local/bin/
cp prometheuspackage/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
cp -r prometheuspackage/consoles /etc/prometheus
cp -r prometheuspackage/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
cp /vagrant/prometheus/prometheus.yml /etc/prometheus/
cp /vagrant/prometheus/prometheus.service /etc/systemd/system/
chown prometheus:prometheus /etc/prometheus/prometheus.yml
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus

#Установка grafana
yum install -y /vagrant/prometheus/grafana_enterprise_9.5.2_1.x86_64-364648-d7217e.rpm 
systemctl daemon-reload
systemctl start grafana-server


