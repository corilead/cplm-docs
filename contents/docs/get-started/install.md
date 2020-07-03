---
title: "系统安装配置(Linux)"
sidebar: Docs
showTitle: true
---
## 安装和配置RabbitMQ
### 前提条件
- 下载erlang
- 下载RabbitMQ

### 安装RabbitMQ
```
sudo chmod +x erlang-22.1.8-1.el7.x86_64.rpm
sudo yum -y install erlang-22.1.8-1.el7.x86_64.rpm
sudo chmod +x rabbitmq-server-3.8.2-1.el7.noarch.rpm
sudo yum -y install rabbitmq-server-3.8.2-1.el7.noarch.rpm
sudo service rabbitmq-server start
```

### 启用管理控制台
```
cd /usr/lib/rabbitmq/lib/rabbitmq_server-3.8.2/ebin
sudo rabbitmq-plugins enable rabbitmq_management
sudo service rabbitmq-server restart
```
访问[http://localhost:15672](http://localhost:15672)，使用默认用户guest/guest登录。

### 创建用户
创建cplm用户并添加到administrator组
```
rabbitmqctl add_user 'cplm' 'cplm'
rabbitmqctl set_user_tags 'cplm' administrator
```

授予cplm用户操作权限
```
rabbitmqctl set_permissions -p '/' 'cplm' '.*' '.*' '.*'
```
## 安装和配置Redis
### 前提条件

### 安装Redis
```
tar -zxvf redis-5.0.7.tar.gz
cd redis-5.0.7
make MALLOC=libc
make install
```

### 启用Redis认证


## 安装和配置ElasticSearch
### 前提条件
- 下载ElasticSearch 6.4.3
- 下载Kibana 6.4.3

### 安装ElasticSearch

### 启用ElasticSearch认证

### 安装Kibana

### 启用Kibana认证


## 安装和配置MySQL
### 前提条件
- 下载MySQL 8.0

### 安装MySQL

