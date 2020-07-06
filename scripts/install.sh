#!/bin/bash

echo 'Install RabbitMQ'
cd ~
wget https://github.com/rabbitmq/erlang-rpm/releases/download/v23.0.2/erlang-23.0.2-1.el7.x86_64.rpm
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.5/rabbitmq-server-3.8.5-1.el7.noarch.rpm

sudo chmod +x erlang-*.rpm
sudo chmod +x rabbitmq-server-*.noarch.rpm
sudo yum -y install erlang-*.rpm
sudo yum -y install rabbitmq-server-*.noarch.rpm
sudo systemctl start rabbitmq-server

sudo rabbitmq-plugins enable rabbitmq_management
sudo systemctl restart rabbitmq-server

sudo rabbitmqctl add_user cplm password
sudo rabbitmqctl set_user_tags cplm administrator
sudo rabbitmqctl set_permissions -p '/' 'cplm' '.*' '.*' '.*'

sudo rabbitmqctl delete_user guest

echo 'Install Redis'
cd ~
wget http://download.redis.io/releases/redis-5.0.8.tar.gz
tar xvzf redis-*.tar.gz
cd redis-*
sudo make install MALLOC=libc

sudo mkdir /etc/redis
sudo mkdir /var/redis
sudo mkdir /var/redis/6379
sudo cp utils/redis_init_script /etc/init.d/redis_6379
sudo cp redis.conf /etc/redis/6379.conf

sudo sed -i 's/^bind 127.0.0.1/# bind 127.0.0.1/g' /etc/redis/6379.conf
sudo sed -i 's/^daemonize .*/daemonize yes/g' /etc/redis/6379.conf
sudo sed -i 's/^# requirepass .*/requirepass password/g' /etc/redis/6379.conf
sudo sed -i 's/^logfile .*/logfile \/var\/log\/redis_6379.log/g' /etc/redis/6379.conf
sudo sed -i 's/^dir .*/dir \/var\/redis\/6379/g' \/etc\/redis\/6379.conf

sudo sed -i 's/$CLIEXEC -p $REDISPORT shutdown/$CLIEXEC -a password -p $REDISPORT shutdown/g' /etc/init.d/redis_6379

sudo chkconfig redis_6379 on
sudo service redis_6379 start

cd ~
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.tar.gz
sudo tar -xzf elasticsearch-*.tar.gz -C /usr/local
sudo mv /usr/local/elasticsearch-* /usr/local/elasticsearch
sudo chown -R cplm: /usr/local/elasticsearch

sudo bash -c 'cat << EOF > /tmp/elasticsearch.service
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

echo 'Install MongoDB'
cd ~
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.8.tgz

sudo tar -zxvf mongodb-linux-*.tgz -C /usr/local
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

echo 'Install Nginx'
cd ~
wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
wget http://zlib.net/zlib-1.2.11.tar.gz
wget http://www.openssl.org/source/openssl-1.1.1g.tar.gz
wget https://nginx.org/download/nginx-1.18.0.tar.gz

cd ~
tar -zxf pcre-*.tar.gz
cd pcre-*
./configure
make
sudo make install

cd ~
tar -zxf zlib-*.tar.gz
cd zlib-*
./configure
make
sudo make install

cd ~
tar -zxf openssl-*.tar.gz
cd openssl-*
./Configure linux-x86_64 --prefix=/usr
make
sudo make install

cd ~
tar zxf nginx-*.tar.gz
cd nginx-*
./configure --prefix=/usr/local/nginx --with-pcre=../pcre-8.44 --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.1.1g --with-http_ssl_module --with-stream
make
sudo make install

sudo bash -c 'cat << EOF > /usr/lib/systemd/system/nginx.service
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF'


sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl start nginx