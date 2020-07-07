#!/bin/bash

#wget https://github.com/alibaba/nacos/releases/download/1.3.0/nacos-server-1.3.0.tar.gz
wget http://192.168.1.111/nacos-server-1.3.0.tar.gz

sudo tar -zxf nacos-server-*.tar.gz -C /usr/local
sudo chown -R cplm: /usr/local/nacos

sudo bash -c 'cat << EOF > /usr/lib/systemd/system/nacos.service
[Unit]
Description=The nacos server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/local/nacos/bin/startup.sh -m standalone
ExecStop=/usr/local/nacos/bin/shutdown.sh
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable nacos
sudo systemctl start nacos