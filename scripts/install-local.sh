#!/bin/bash
export DOWNLOAD_PACKAGE=false

./install-rabbitmq.sh

./install-redis.sh

./install-elasticsearch.sh

./install-mongodb.sh

./install-nginx.sh

./install-nacos.sh

