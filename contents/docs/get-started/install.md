---
title: "系统安装配置(Linux)"
sidebar: Docs
showTitle: true
---
## 准备工作
- 安装CentOS 7.x
- 安装Development Tools
- 修改内核参数
- 安装Java SDK 8
- 安装Apache Maven 3


## 安装和配置RabbitMQ
### 前提条件
- 下载[erlang 23.0.2](https://github.com/rabbitmq/erlang-rpm/releases/download/v23.0.2/erlang-23.0.2-1.el7.x86_64.rpm)
- 下载[RabbitMQ 3.8.5](https://packagecloud.io/rabbitmq/rabbitmq-server/packages/el/7/rabbitmq-server-3.8.5-1.el7.noarch.rpm)

### 安装RabbitMQ
```
sudo chmod +x erlang-23.0.2-1.el7.x86_64.rpm
sudo yum -y install erlang-23.0.2-1.el7.x86_64.rpm
sudo chmod +x rabbitmq-server-3.8.5-1.el7.noarch.rpm
sudo yum -y install rabbitmq-server-3.8.5-1.el7.noarch.rpm
sudo service rabbitmq-server start
```

### 启用管理控制台
```
cd /usr/lib/rabbitmq/lib/rabbitmq_server-3.8.5/ebin
sudo rabbitmq-plugins enable rabbitmq_management
sudo service rabbitmq-server restart
```
访问[http://localhost:15672](http://localhost:15672)，使用默认用户guest/guest登录。

### 创建用户
创建cplm用户并设置权限
```bash
rabbitmqctl add_user cplm password
rabbitmqctl set_user_tags cplm administrator
rabbitmqctl set_permissions -p '/' 'cplm' '.*' '.*' '.*'
```
**注意：将password修改为需要设置的密码。**

### 删除默认用户
```bash
rabbitmqctl delete_user guest
```

## 安装和配置Redis
### 前提条件
- 下载[Redis 5.0.8](http://download.redis.io/releases/redis-5.0.8.tar.gz)

### 安装Redis
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

### 修改Redis配置文件
- 取消绑定本机IP
- 设置为守护进程
- 启用认证密码
- 设置日志文件
- 设置数据文件夹
```bash
sudo sed -i 's/^bind 127.0.0.1/# bind 127.0.0.1/g' /etc/redis/6379.conf
sudo sed -i 's/^daemonize .*/daemonize yes/g' /etc/redis/6379.conf
sudo sed -i 's/^# requirepass .*/requirepass **password**/g' /etc/redis/6379.conf
sudo sed -i 's/^logfile .*/logfile \/var\/log\/redis_6379.log/g' /etc/redis/6379.conf
sudo sed -i 's/^dir .*/dir /var/redis/6379/g' \/etc\/redis\/6379.conf
```
**注意：将password修改为需要设置的密码。**

### 修改Redis启动脚本
- 设置认证密码
```bash
sudo sed -i 's/$CLIEXEC -p $REDISPORT shutdown/$CLIEXEC -a password -p $REDISPORT shutdown/g' /etc/init.d/redis_6379
```
**注意：将password修改为前面步骤设置的密码。**

### 启动Redis
注册为系统服务，并且启动redis服务
```bash
sudo chkconfig redis_6379 on
sudo service redis_6379 start
```

### 检查Redis运行状态
```bash
$ redis-cli
127.0.0.1:6379> auth password
OK
127.0.0.1:6379> ping
PONG
```
**注意：将password修改为前面步骤设置的密码。**

## 安装和配置ElasticSearch
### 前提条件
- 下载[ElasticSearch 6.4.3](https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.3.tar.gz)
- 下载[Kibana 6.4.3](https://artifacts.elastic.co/downloads/kibana/kibana-6.4.3-linux-x86_64.tar.gz)

### 安装ElasticSearch

### 启用ElasticSearch认证

### 安装Kibana

### 启用Kibana认证


## 安装和配置MongoDB
### 前提条件

## 安装和配置MySQL
### 前提条件
- 下载MySQL 8.0

### 安装MySQL

