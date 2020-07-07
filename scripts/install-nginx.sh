#!/bin/bash

cd ~
#wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
#wget http://zlib.net/zlib-1.2.11.tar.gz
#wget http://www.openssl.org/source/openssl-1.1.1g.tar.gz
#wget https://nginx.org/download/nginx-1.18.0.tar.gz


wget http://192.168.1.111/pcre-8.44.tar.gz
wget http://192.168.1.111/zlib-1.2.11.tar.gz
wget http://192.168.1.111/openssl-1.1.1g.tar.gz
wget http://192.168.1.111/nginx-1.18.0.tar.gz

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