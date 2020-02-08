#!/bin/bash
dir=$(pwd)
echo "current dir: $dir"

yum -y install vim
yum -y install wget

cd /root
useradd -m -s /bin/false node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar -zxpvf node_exporter-0.18.1.linux-amd64.tar.gz
cp node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin
chown node_exporter:node_exporter /usr/local/bin/node_exporter

echo "writing /etc/systemd/system/node_exporter.service"
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
cat /etc/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

echo "Verifying status node_exporter"
systemctl status node_exporter

firewall-cmd --permanent --add-port=9100/tcp
firewall-cmd --reload

echo "Verifying port FIREWALL"
firewall-cmd --list-all
echo "Verifying port LISTENING PORT"
netstat -nlptu

ip_addr=$(ip address show dev eth0 | grep inet.*eth0 | awk '{print $2}'| cut -f1 -d/)
echo "node_exporter client:"
echo "- targets: ['$ip_addr:9100']"
