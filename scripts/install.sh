
echo 'Install RabbitMQ'
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