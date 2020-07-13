---
title: "快速开始"
sidebar: Docs
showTitle: true
---
## 基础环境配置
### 安装和配置Git客户端
1. 下载并按照默认配置安装Git客户端(https://git-scm.com/downloads)
2. 下载并按照默认配置安装TortoiseGit(https://tortoisegit.org/download/)

### 安装和配置JDK
1. 下载并安装JDK 8，建议选用AdoptOpenJDK(https://adoptopenjdk.net/)，版本选择OpenJDK 8 (LTS)，JVM选择HotSpot
2. 配置环境变量JAVA_HOME，指向JDK的安装根文件夹
3. 配置环境变量PATH，增加%JAVA_HOME%/bin
4. 打开命令行控制台，执行java -version命令检查JDK安装成功

## 安装和配置数据库
### 安装MySQL软件

#### Windows

1. 下载MySQL安装文件[mysql-installer-community-8.0.20.0.msi](https://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-community-8.0.20.0.msi)
2. 双击mysql-installer-community-8.0.20.0.msi文件，按照默认步骤安装

#### Linux/Unix/Mac

```

```

### 新建认证服务数据库和用户

```sql
mysql -uroot -p

mysql> CREATE DATABASE cplm_auth DEFAULT CHARACTER SET utf8mb4;
mysql> CREATE USER 'cplm_auth'@'%' IDENTIFIED BY 'cplm_auth';
mysql> GRANT ALL PRIVILEGES ON cplm_auth.* TO 'cplm_auth'@'%';
mysql> exit
```

### 新建示例服务数据库和用户

```sql
mysql -uroot -p

mysql> CREATE DATABASE cplm_samples DEFAULT CHARACTER SET utf8mb4;
mysql> CREATE USER 'cplm_samples'@'%' IDENTIFIED BY 'cplm_samples';
mysql> GRANT ALL PRIVILEGES ON cplm_samples.* TO 'cplm_samples'@'%';
mysql> exit
```



## 安装和配置Nacos

### 安装和启动服务

#### Windows

1. 下载Nacos安装文件[nacos-server-1.3.1.zip](https://github.com/alibaba/nacos/releases/download/1.3.1/nacos-server-1.3.1.zip)
2. 解压nacos-server-1.3.1.zip
3. 进入nacos-server-1.3.1/bin文件夹
4. 双击startup.cmd启动服务


#### Linux/Unix/Mac
```sh
wget https://github.com/alibaba/nacos/releases/download/1.3.1/nacos-server-1.3.1.tar.gz
sudo tar -zxf nacos-server-*.tar.gz -C /usr/local
sudo chown -R cplm: /usr/local/nacos
/usr/local/nacos/bin/startup.sh -m standalone
```

### 新建配置

#### 新建认证服务的配置

1. 浏览器访问[http://localhost:8084/nacos](http://localhost:8084/nacos)
2. 进入配置管理 > 配置列表,点击**新建配置**图标
3. Data ID输入**cplm-cloud-uaa.properties**，配置格式选择 **Properties**，输入以下配置内容，点击**发布**按钮

```properties
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
spring.datasource.url=jdbc:mysql://localhost:3306/cplm-uaa?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=cplm-uaa
spring.datasource.password=cplm-uaa
spring.datasource.driver-class-name=com.mysql.jdbc.Drive
```

#### 新建示例服务的配置

1. 浏览器访问[http://localhost:8084/nacos](http://localhost:8084/nacos)
2. 进入配置管理 > 配置列表,点击**新建配置**图标
3. Data ID输入**cplm-cloud-samples.properties**，配置格式选择 **Properties**，输入以下配置内容，点击**发布**按钮

```sh
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
spring.datasource.url=jdbc:mysql://localhost:3306/cplm-samples?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=cplm-samples
spring.datasource.password=cplm-samples
spring.datasource.driver-class-name=com.mysql.jdbc.Drive
```

## 启动CPLM服务

### 启动认证项目

### 启动网关服务

### 启动基础服务

### 启动示例项目

```sh
git clone http://git.corilead.com/cplm/cplm-cloud-samples.git
cd cplm-cloud-samples
mvnw clean package -s settings.xml
cd cplm-cloud-samples-app/target
java -jar cplm-cloud-samples-app.jar
```

浏览器访问[http://localhost:8080](http://localhost:8080)