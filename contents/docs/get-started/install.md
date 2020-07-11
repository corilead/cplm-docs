---
title: 系统安装配置(Linux)
sidebar: Docs
showTitle: true
---

## 准备工作
- 安装CentOS 7.x
- 安装Development Tools

## 自动安装

### 执行安装脚本

```sh
wget -O - http://git.corilead.com/cplm/cplm-cloud-deploy/raw/master/scripts/install.sh | bash
```

### 检查运行状态

参照手动安装各章节的检查运行状态步骤。

## 手动安装

### 安装第三方类库

```sh
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/socat-1.7.3.2-2.el7.x86_64.rpm

sudo yum -y install socat-*.rpm
```

### 安装OpenJDK

下载软件

```sh
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/java-1.8.0-openjdk-devel-1.8.0.242.b08-1.el7.x86_64.rpm
```

安装OpenJDK

```sh
yum -y install java-1.8.0-openjdk-devel-*.rpm
```

设置环境变量

```sh
echo export JAVA_HOME='$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")' | tee /etc/profile.d/java_home.sh > /dev/null
source /etc/source
```

### 安装和配置RabbitMQ

#### 下载软件
- 下载[erlang 23.0.2](https://github.com/rabbitmq/erlang-rpm/releases/download/v23.0.2/erlang-23.0.2-1.el7.x86_64.rpm)
- 下载[RabbitMQ 3.8.5](https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.5/rabbitmq-server-3.8.5-1.el7.noarch.rpm)
```sh
wget https://github.com/rabbitmq/erlang-rpm/releases/download/v23.0.2/erlang-23.0.2-1.el7.x86_64.rpm
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.5/rabbitmq-server-3.8.5-1.el7.noarch.rpm
```

#### 安装RabbitMQ
```sh
sudo chmod +x erlang-*.rpm
sudo chmod +x rabbitmq-server-*.noarch.rpm
sudo yum -y install erlang-*.rpm
sudo yum -y install rabbitmq-server-*.noarch.rpm

sudo systemctl daemon-reload
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server
```

#### 启用管理控制台
```sh
sudo rabbitmq-plugins enable rabbitmq_management
sudo systemctl restart rabbitmq-server
```

#### 创建用户
创建rabbitmq用户并设置权限
```bash
sudo rabbitmqctl add_user cplm password
sudo rabbitmqctl set_user_tags cplm administrator
sudo rabbitmqctl set_permissions -p '/' 'cplm' '.*' '.*' '.*'
```
**注意：将password修改为需要设置的密码。**

#### 删除默认用户
```bash
sudo rabbitmqctl delete_user guest
```

#### 检查运行状态
访问[http://localhost:15672](http://localhost:15672)，使用新创建的用户登录。

### 安装和配置Redis
#### 下载软件
- 下载[Redis 5.0.8](http://download.redis.io/releases/redis-5.0.8.tar.gz)
```sh
wget http://download.redis.io/releases/redis-5.0.8.tar.gz
```

#### 安装Redis
```sh
tar -zxf redis-*.tar.gz
cd redis-*
sudo make install MALLOC=libc

sudo mkdir -p /var/redis
sudo mkdir -p /var/redis/6379
sudo cp utils/redis_init_script /etc/init.d/redis_6379
sudo cp redis.conf /etc/redis/6379.conf
```

#### 修改配置文件

- 取消绑定本机IP
- 设置为守护进程
- 启用认证密码
- 设置日志文件
- 设置数据文件夹
```bash
sudo sed -i 's/^bind 127.0.0.1/# bind 127.0.0.1/g' /etc/redis/6379.conf
sudo sed -i 's/^daemonize .*/daemonize yes/g' /etc/redis/6379.conf
sudo sed -i 's/^# requirepass .*/requirepass password/g' /etc/redis/6379.conf
sudo sed -i 's/^logfile .*/logfile \/var\/log\/redis_6379.log/g' /etc/redis/6379.conf
sudo sed -i 's/^dir .*/dir \/var\/redis\/6379/g' \/etc\/redis\/6379.conf
```
**注意：将password修改为需要设置的密码。**

#### 修改启动脚本
- 设置认证密码
```bash
sudo sed -i 's/$CLIEXEC -p $REDISPORT shutdown/$CLIEXEC -a password -p $REDISPORT shutdown/g' /etc/init.d/redis_6379
```
**注意：将password修改为前面步骤设置的密码。**

#### 启动服务
注册为系统服务，并且启动redis服务
```bash
sudo chkconfig redis_6379 on
sudo service redis_6379 start
```

#### 检查运行状态
```bash
$ redis-cli
127.0.0.1:6379> auth password
OK
127.0.0.1:6379> ping
PONG
127.0.0.1:6379> exit
```
**注意：将password修改为前面步骤设置的密码。**

### 安装和配置ElasticSearch
#### 下载软件
- 下载[ElasticSearch 6.4.3](https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.tar.gz)
```sh
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.tar.gz
```

#### 安装ElasticSearch
```sh
sudo tar -zxf elasticsearch-*.tar.gz -C /usr/local
sudo mv /usr/local/elasticsearch-* /usr/local/elasticsearch
sudo chown -R cplm: /usr/local/elasticsearch
```

#### 启用用户认证

#### 注册系统服务
```sh
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
```

#### 启动服务

```sh
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
```

#### 检查运行状态
访问[http://localhost:9200](http://localhost:9200)，页面显示Elasticsearch版本信息。

### 安装和配置Kibana

#### 下载软件

- 下载[Kibana 6.4.3](https://artifacts.elastic.co/downloads/kibana/kibana-6.4.3-linux-x86_64.tar.gz)

```sh
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.4.3-linux-x86_64.tar.gz
```

#### 安装Kibana

```sh
sudo tar -zxf kibana-*.tar.gz -C /usr/local
sudo mv /usr/local/kibana-* /usr/local/kibana
sudo chown -R cplm: /usr/local/kibana
```

#### 启用Kibana认证

#### 注册系统服务

```sh
sudo bash -c 'cat << EOF > /usr/lib/systemd/system/kibana.service
[Unit]
Description=Kibana
Documentation=http://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
PrivateTmp=true
User=cplm

ExecStart=/usr/local/kibana/bin/kibana

[Install]
WantedBy=multi-user.target
EOF'
```

#### 启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana
```

#### 检查运行状态

访问[localhost:5601/status](localhost:5601/status)，页面显示Kibana状态信息。


### 安装和配置MongoDB
#### 下载软件
- 下载[MongoDB 4.2.8](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.8.tgz)
```
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.8.tgz
```

#### 安装MongoDB
```bash
sudo tar -zxf mongodb-linux-*.tgz -C /usr/local
sudo mv /usr/local/mongodb-* /usr/local/mongodb
sudo chown -R cplm: /usr/local/mongodb

sudo mkdir -p /var/lib/mongodb
sudo mkdir -p /var/log/mongodb
sudo chown -R cplm: /var/lib/mongodb
sudo chown -R cplm: /var/log/mongodb
```

#### 创建配置文件
```properties
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
```

#### 注册系统服务
```sh
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
```

#### 启动服务
```sh
sudo systemctl daemon-reload
sudo systemctl enable mongodb
sudo systemctl start mongodb
```

### 安装和配置Nginx
#### 下载软件
- 下载[PCRE](https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz)
- 下载[zlib](http://zlib.net/zlib-1.2.11.tar.gz)
- 下载[OpenSSL](http://www.openssl.org/source/openssl-1.1.1g.tar.gz)
- 下载[Nginx 1.18.0](https://nginx.org/download/nginx-1.18.0.tar.gz)
```sh
wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
wget http://zlib.net/zlib-1.2.11.tar.gz
wget http://www.openssl.org/source/openssl-1.1.1g.tar.gz
wget https://nginx.org/download/nginx-1.18.0.tar.gz
```

#### 安装依赖软件
安装PCER
```sh
tar -zxf pcre-*.tar.gz
cd pcre-*
./configure
make
sudo make install
```

安装zlib
```sh
tar -zxf zlib-*.tar.gz
cd zlib-*
./configure
make
sudo make install
```

安装OpenSSL
```sh
tar -zxf openssl-*.tar.gz
cd openssl-*
./Configure linux-x86_64 --prefix=/usr
make
sudo make install
```

#### 安装Nginx
```sh
tar -zxf nginx-*.tar.gz
cd nginx-*
./configure --prefix=/usr/local/nginx --with-pcre=../pcre-8.44 --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.1.1g --with-http_ssl_module --with-stream
make
sudo make install
```

#### 注册系统服务
```sh
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
```

#### 启动服务
```sh
sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl start nginx
```

#### 检查运行状态
访问[http://localhost](http://localhost)，页面显示“Welcome to nginx!”。


### 安装和配置MySQL
#### 下载软件
- 下载[MySQL 8.0](https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz)
```sh
wget https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz
```

#### 安装MySQL

```sh
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
cd /usr/local
tar zxvf /path/to/mysql-VERSION-OS.tar.gz
ln -s full-path-to-mysql-VERSION-OS mysql
cd mysql
mkdir mysql-files
chown mysql:mysql mysql-files
chmod 750 mysql-files
bin/mysqld --initialize --user=mysql
bin/mysql_ssl_rsa_setup
bin/mysqld_safe --user=mysql &
cp support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
chkconfig --add mysql
```



```
systemctl start mysqld
```



### 安装和配置Nacos
#### 下载软件

```sh
wget https://github.com/alibaba/nacos/releases/download/1.3.0/nacos-server-1.3.0.tar.gz
```

#### 安装软件

```sh
sudo tar -zxf nacos-server-*.tar.gz -C /usr/local
sudo chown -R cplm: /usr/local/nacos
```

#### 注册系统服务

```sh
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
```

#### 启动服务

```sh
sudo systemctl daemon-reload
sudo systemctl enable nacos
sudo systemctl start nacos
```

#### 检查运行状态

访问[http://localhost:8848/nacos](http://localhost:8848/nacos)，使用默认用户nacos/nacos登录