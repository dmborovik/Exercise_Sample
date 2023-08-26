#!/bin/bash
yum install wget -y
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xzfv node_exporter-1.6.1.linux-amd64.tar.gz
useradd -rs /bin/false nodeusr
cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter
cp /vagrant/host/node_exporter.service /etc/systemd/system
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

