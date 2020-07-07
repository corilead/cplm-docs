#!/bin/bash

cd ~
#wget http://download.redis.io/releases/redis-5.0.8.tar.gz
wget http://192.168.1.111/redis-5.0.8.tar.gz

tar xzf redis-*.tar.gz
cd redis-*
sudo make install MALLOC=libc

sudo mkdir -p /etc/redis
sudo mkdir -p /var/redis
sudo mkdir -p /var/redis/6379
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