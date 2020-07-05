---
title: "系统安装配置(Linux)"
sidebar: Docs
showTitle: true
---
## 准备工作
- 安装CentOS 7.x
- 安装Development Tools

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

### 安装Java SDK

### 安装Apache Maven

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
sudo chmod +x erlang-23.0.2-1.el7.x86_64.rpm
sudo yum -y install erlang-23.0.2-1.el7.x86_64.rpm
sudo chmod +x rabbitmq-server-3.8.5-1.el7.noarch.rpm
sudo yum -y install rabbitmq-server-3.8.5-1.el7.noarch.rpm
sudo service rabbitmq-server start
```

#### 启用管理控制台
```
cd /usr/lib/rabbitmq/lib/rabbitmq_server-3.8.5/ebin
sudo rabbitmq-plugins enable rabbitmq_management
sudo service rabbitmq-server restart
```
访问[http://localhost:15672](http://localhost:15672)，使用默认用户guest/guest登录。

#### 创建用户
创建rabbitmq用户并设置权限
```bash
rabbitmqctl add_user cplm password
rabbitmqctl set_user_tags cplm administrator
rabbitmqctl set_permissions -p '/' 'cplm' '.*' '.*' '.*'
```
**注意：将password修改为需要设置的密码。**

#### 删除默认用户
```bash
rabbitmqctl delete_user guest
```

### 安装和配置Redis
#### 下载软件
- 下载[Redis 5.0.8](http://download.redis.io/releases/redis-5.0.8.tar.gz)
```
http://download.redis.io/releases/redis-5.0.8.tar.gz
```

#### 安装Redis
```
tar xvzf redis-5.0.8.tar.gz
cd redis-5.0.8
sudo make install MALLOC=libc

sudo mkdir /etc/redis
sudo mkdir /var/redis
sudo mkdir /var/redis/6379
sudo cp utils/redis_init_script /etc/init.d/redis_6379
sudo cp redis.conf /etc/redis/6379.conf
```

#### 修改Redis配置文件
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
sudo sed -i 's/^dir .*/dir /var/redis/6379/g' \/etc\/redis\/6379.conf
```
**注意：将password修改为需要设置的密码。**

#### 修改Redis启动脚本
- 设置认证密码
```bash
sudo sed -i 's/$CLIEXEC -p $REDISPORT shutdown/$CLIEXEC -a password -p $REDISPORT shutdown/g' /etc/init.d/redis_6379
```
**注意：将password修改为前面步骤设置的密码。**

#### 启动Redis
注册为系统服务，并且启动redis服务
```bash
sudo chkconfig redis_6379 on
sudo service redis_6379 start
```

#### 检查Redis运行状态
```bash
$ redis-cli
127.0.0.1:6379> auth password
OK
127.0.0.1:6379> ping
PONG
```
**注意：将password修改为前面步骤设置的密码。**

### 安装和配置ElasticSearch
#### 下载软件
- 下载[ElasticSearch 6.4.3](https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.tar.gz)
- 下载[Kibana 6.4.3](https://artifacts.elastic.co/downloads/kibana/kibana-6.4.3-linux-x86_64.tar.gz)
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.tar.gz
wget ttps://artifacts.elastic.co/downloads/kibana/kibana-6.4.3-linux-x86_64.tar.gz
```

#### 安装ElasticSearch(.tar.gz格式)
安装ElasticSearch
```
tar -xzf elasticsearch-6.4.3.tar.gz
cd elasticsearch-6.4.3
```
启动ElasticSearch
```
./bin/elasticsearch -d -p pid
```


#### 安装ElasticSearch(.rpm格式)
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.rpm
sudo rpm --install elasticsearch-6.4.3.rpm
sudo chkconfig --add elasticsearch
sudo -i service elasticsearch start
```

#### 启用ElasticSearch认证

#### 安装Kibana

```

```

#### 安装Kibana

#### 启用Kibana认证


### 安装和配置MongoDB
#### 下载软件
- 下载[MongoDB 4.2.8](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.8.tgz)
```
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.8.tgz
```

#### 安装MongoDB
```bash
tar -zxvf mongodb-linux-x86_64-rhel70-4.2.8.tgz
sudo cp /path/to/the/mongodb-directory/bin/* /usr/local/bin/
sudo ln -s  /path/to/the/mongodb-directory/bin/* /usr/local/bin/

sudo mkdir -p /var/lib/mongo
sudo mkdir -p /var/log/mongodb
sudo chown -R mongod:mongod /var/lib/mongo
sudo chown -R mongod:mongod /var/log/mongodb
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
tar -zxf pcre-8.44.tar.gz
cd pcre-8.44
./configure
make
sudo make install
```

安装zlib
```
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
sudo make install
```

安装OpenSSL
```
tar -zxf openssl-1.1.1g.tar.gz
cd openssl-1.1.1g
./Configure linux-x86_64 --prefix=/usr
make
sudo make install
```

#### 安装Nginx
```
tar zxf nginx-1.18.0.tar.gz
cd nginx-1.18.0
./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/usr/local/nginx/nginx.pid --with-pcre=../pcre-8.44 --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.1.1.g --with-http_ssl_module --with-stream
```

### 安装和配置MySQL
#### 下载软件
- 下载MySQL 8.0

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
#### 前提