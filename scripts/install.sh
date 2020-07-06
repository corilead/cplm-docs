
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

