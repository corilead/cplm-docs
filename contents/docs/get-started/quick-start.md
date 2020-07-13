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

## 启动示例项目

```
git clone http://git.corilead.com/cplm/cplm-cloud-samples.git
cd cplm-cloud-samples
mvnw clean package -s settings.xml
cd cplm-cloud-samples-app/target
java -DCPLM_NACOS_SERVER=nacos.corilead.com -jar cplm-cloud-samples-app.jar
```

浏览器访问[http://localhost:8080](http://localhost:8080)