#!/bin/bash
dir=$(pwd)
echo "current dir: $dir"

yum -y install vim
yum -y install wget
useradd -m -s /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus /var/lib/prometheus/
wget https://github.com/prometheus/prometheus/releases/download/v2.15.2/prometheus-2.15.2.linux-amd64.tar.gz -P /tmp
cd /tmp/
tar -zxpvf prometheus-2.15.2.linux-amd64.tar.gz
cd prometheus-2.15.2.linux-amd64
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/

echo "writing /etc/prometheus/prometheus.yml"
cat <<EOF > /etc/prometheus/prometheus.yml
# Global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute. 
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute. 
  scrape_timeout: 15s  # scrape_timeout is set to the global default (10s).
# A scrape configuration containing exactly one endpoint to scrape:# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
    - targets: ['localhost:9090']
EOF
cat /etc/prometheus/prometheus.yml

firewall-cmd --permanent --add-port=9090/tcp
firewall-cmd --reload

cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Time Series Collection and Processing Server
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
cat /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus

echo "Verifying status prometheus"
systemctl status prometheus

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

echo "writing /etc/prometheus/prometheus.yml"
cat <<EOF >> /etc/prometheus/prometheus.yml

EOF
cat /etc/prometheus/prometheus.yml

systemctl restart prometheus

echo "Verifying port FIREWALL"
firewall-cmd --list-all
echo "Verifying port LISTENING PORT"
netstat -nlptu

ip_addr=$(ip address show dev eth0 | grep inet.*eth0 | awk '{print $2}'| cut -f1 -d/)
echo "node_exporter client:"
echo "- targets: ['$ip_addr:9100']"
