#!/bin/bash

cd ~
#wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.tar.gz
wget http://192.168.1.111/elasticsearch-6.4.3.tar.gz


sudo tar -xzf elasticsearch-*.tar.gz -C /usr/local
sudo mv /usr/local/elasticsearch-* /usr/local/elasticsearch
sudo chown -R cplm: /usr/local/elasticsearch

sudo bash -c 'cat << EOF > /usr/lib/systemd/system/elasticsearch.service
[Unit]
Description=Elasticsearch
Documentation=http://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
PrivateTmp=true
User=cplm

ExecStart=/usr/local/elasticsearch/bin/elasticsearch -p /usr/local/elasticsearch/logs/elasticsearch.pid --quiet

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of processes
LimitNPROC=4096

# Specifies the maximum size of virtual memory
LimitAS=infinity

# Specifies the maximum file size
LimitFSIZE=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0

# SIGTERM signal is used to stop the Java process
KillSignal=SIGTERM

# Send the signal only to the JVM rather than its control group
KillMode=process

# Java process is never killed
SendSIGKILL=no

# When a JVM receives a SIGTERM signal it exits with code 143
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch