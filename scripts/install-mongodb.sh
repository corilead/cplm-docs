#!/bin/bash

cd ~
#wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.8.tgz
wget http://192.168.1.111/mongodb-linux-x86_64-rhel70-4.2.8.tgz

sudo tar -zxf mongodb-linux-*.tgz -C /usr/local
sudo mv /usr/local/mongodb-* /usr/local/mongodb
sudo chown -R cplm: /usr/local/mongodb

sudo mkdir -p /var/lib/mongodb
sudo mkdir -p /var/log/mongodb
sudo chown -R cplm: /var/lib/mongodb
sudo chown -R cplm: /var/log/mongodb

sudo bash -c 'cat << EOF > /usr/local/etc/mongod.conf
systemLog:
  destination: file
  path: /var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /var/lib/mongodb
net:
  bindIpAll: true
EOF'

sudo bash -c 'cat << EOF > /usr/lib/systemd/system/mongodb.service
[Unit]
Description=MongoDB Database Service
Wants=network.target
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/mongodb/bin/mongod --config /usr/local/etc/mongod.conf --fork
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
User=cplm
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable mongodb
sudo systemctl start mongodb