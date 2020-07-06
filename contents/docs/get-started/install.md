---
title: 系统安装配置(Linux)
sidebar: Docs
showTitle: true
---

## 准备工作
- 安装CentOS 7.x
- 安装Development Tools

### 安装第三方类库

#### 下载软件

```
wget https://access.cdn.redhat.com/content/origin/rpms/socat/1.7.3.2/2.el7/fd431d51/socat-1.7.3.2-2.el7.x86_64.rpm?user=&_auth_=1593997397_05703a7853c98e2a8bd5c825262963fe
```

安装

```
sudo yum -y install socat-*.ramp
```



### 创建操作系统用户

以root用户登录，创建用户并设置密码
```
echo 'cplm ALL=(ALL) ALL' >> /etc/sudoers
groupadd cinstall
useradd -g cinstall cplm
passwd cplm
```
将以下配置添加到“/etc/security/limits.conf”文件
```
cplm              soft    nproc   2047
cplm              hard    nproc   16384
cplm              soft    nofile  4096
cplm              hard    nofile  65536
cplm              soft    stack   10240 
```

**注意：以下操作如无特殊说明，均以cplm用户操作。**

## 自动安装

## 手动安装

### 安装和配置RabbitMQ
#### 下载软件
- 下载[erlang 23.0.2](https://github.com/rabbitmq/erlang-rpm/releases/download/v23.0.2/erlang-23.0.2-1.el7.x86_64.rpm)
- 下载[RabbitMQ 3.8.5](https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.5/rabbitmq-server-3.8.5-1.el7.noarch.rpm)
```
wget https://github.com/rabbitmq/erlang-rpm/releases/download/v23.0.2/erlang-23.0.2-1.el7.x86_64.rpm
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.5/rabbitmq-server-3.8.5-1.el7.noarch.rpm
```

#### 安装RabbitMQ
```
sudo chmod +x erlang-*.rpm
sudo yum -y install erlang-*.rpm
sudo chmod +x rabbitmq-server-*.noarch.rpm
sudo yum -y install rabbitmq-server-*.noarch.rpm
sudo service rabbitmq-server start
```

#### 启用管理控制台
```
sudo rabbitmq-plugins enable rabbitmq_management
sudo service rabbitmq-server restart
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
```
wget http://download.redis.io/releases/redis-5.0.8.tar.gz
```

#### 安装Redis
```
tar xvzf redis-*.tar.gz
cd redis-*
sudo make install MALLOC=libc

sudo mkdir /etc/redis
sudo mkdir /var/redis
sudo mkdir /var/redis/6379
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
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.tar.gz
```

#### 安装ElasticSearch
```
sudo tar -xzf elasticsearch-*.tar.gz -C /usr/local
sudo mv /usr/local/elasticsearch-* /usr/local/elasticsearch
sudo chown -R cplm: /usr/local/elasticsearch
```

#### 启用用户认证

#### 注册系统服务
新建systemd文件/usr/lib/systemd/system/elasticsearch.service
```
sudo vi /usr/lib/systemd/system/elasticsearch.service
```

文件内容如下
```
[Unit]
Description=Elasticsearch
Documentation=http://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
PrivateTmp=true
User=cplm

ExecStart=/usr/share/elasticsearch/bin/elasticsearch -p /usr/share/elasticsearch/logs/elasticsearch.pid --quiet

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
```

#### 启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
```

#### 检查运行状态
访问[http://localhost:9200](http://localhost:9200)，页面显示Elasticsearch版本信息。

### 安装和配置Kibana

#### 下载软件

- 下载[Kibana 6.4.3](https://artifacts.elastic.co/downloads/kibana/kibana-6.4.3-linux-x86_64.tar.gz)

```
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.4.3-linux-x86_64.tar.gz
```

#### 安装Kibana

```
sudo tar -xzf kibana-*.tar.gz -C /usr/local
sudo mv /usr/local/kibana-* /usr/local/kibana
sudo chown -R cplm: /usr/local/kibana
```

#### 启用Kibana认证

#### 注册系统服务

新建systemd文件/usr/lib/systemd/system/kibana.service

```
sudo vi /usr/lib/systemd/system/kibana.service
```

文件内容如下

```
[Unit]
Description=Kibana
Documentation=http://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
PrivateTmp=true
User=cplm

ExecStart=/usr/share/kibana/bin/kibana

[Install]
WantedBy=multi-user.target
```

#### 启动服务

```
sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana
```

#### 检查运行状态

访问[localhost:5601/status](localhost:5601/status)，页面显示Kibana状态信息。

#### 启动服务


### 安装和配置MongoDB
#### 下载软件
- 下载[MongoDB 4.2.8](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.8.tgz)
```
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.8.tgz
```

#### 安装MongoDB
```bash
sudo tar -zxvf mongodb-linux-*.tgz -C /usr/local
sudo mv /usr/local/mongodb-* /usr/local/mongodb
sudo chown -R cplm: /usr/local/mongodb

sudo mkdir -p /var/lib/mongodb
sudo mkdir -p /var/log/mongodb
sudo chown -R cplm: /var/lib/mongodb
sudo chown -R cplm: /var/log/mongodb
```

#### 修改配置
新建文件/usr/local/etc/mongod.conf
```bash
sudo vi /usr/local/etc/mongod.conf
```

文件内容如下：
```
systemLog:
  destination: file
  path: /var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /var/lib/mongodb
net:
  bindIp: 127.0.0.1
```

#### 注册系统服务
新建systemd文件/usr/lib/systemd/system/mongodb.service
```bash
sudo vi /usr/lib/systemd/system/mongodb.service
```

文件内容如下
```
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
```

#### 启动服务
```
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
```
wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
wget http://zlib.net/zlib-1.2.11.tar.gz
wget http://www.openssl.org/source/openssl-1.1.1g.tar.gz
wget https://nginx.org/download/nginx-1.18.0.tar.gz
```

#### 安装依赖软件
安装PCER
```
tar -zxf pcre-*.tar.gz
cd pcre-*
./configure
make
sudo make install
```

安装zlib
```
tar -zxf zlib-*.tar.gz
cd zlib-*
./configure
make
sudo make install
```

安装OpenSSL
```
tar -zxf openssl-*.tar.gz
cd openssl-*
./Configure linux-x86_64 --prefix=/usr
make
sudo make install
```

#### 安装Nginx
```
tar zxf nginx-*.tar.gz
cd nginx-*
./configure --prefix=/usr/local/nginx --with-pcre=../pcre-8.44 --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.1.1g --with-http_ssl_module --with-stream
make
sudo make install
```

#### 注册系统服务
新建systemd文件/usr/lib/systemd/system/nginx.service
```
sudo vi /usr/lib/systemd/system/nginx.service
```

文件内容如下
```
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
```

#### 启动服务
```
sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl start nginx
```

#### 检查运行状态
访问[http://localhost](http://localhost)，页面显示“Welcome to nginx!”。


### 安装和配置MySQL
#### 下载软件
- 下载[MySQL 8.0](https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz)
```
cd ~
wget https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-8.0.20-linux-glibc2.12-x86_64.tar.xz
```

#### 安装MySQL


### 安装和配置达梦
#### 前提条件
- 达梦8安装软件
- 达梦8许可文件

#### 创建用户和组
使用root用户登录创建数据库安装用户
```
groupadd dinstall
useradd -g dinstall -m -d /home/dmdba -s /bin/bash dmdba
echo 'dmdba ALL=(ALL) ALL' >> /etc/sudoers

passwd dmdba
```

#### 安装数据库
使用上一步创建新建的用户登录，执行数据库安装
```
mkdir /mnt/cdrom
mount /dev/cdrom /mnt/cdrom
chmod a+rx dmdbms-8.2-1.x86_64.rpm
sudo rpm -ivh dmdbms-8.2-1.x86_64.rpm
```

```
sudo ./dminit PATH=/var/dmdbms PAGE_SIZE=16
```

### 安装和配置Nacos
#### 下载软件