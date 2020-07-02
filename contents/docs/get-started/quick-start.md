---
title: "开发环境配置"
metaTitle: "Syntax Highlighting is the meta title tag for this page"
metaDescription: "This is the meta description for this page"
---
# 开发环境配置

## 基础开发环境配置

### 安装和配置Git客户端

1. 下载并按照默认配置安装Git客户端(https://git-scm.com/downloads)
2. 下载并按照默认配置安装TortoiseGit(https://tortoisegit.org/download/)



## 前端开发环境配置

### 安装和配置NodeJS



### 安装和配置Yarn



### 安装和配置Visual Studio Code



## Java开发环境配置

### 安装和配置JDK

1. 下载并安装JDK 8，建议选用AdoptOpenJDK(https://adoptopenjdk.net/)，版本选择OpenJDK 8 (LTS)，JVM选择HotSpot
2. 配置环境变量JAVA_HOME，指向JDK的安装根文件夹
3. 配置环境变量PATH，增加%JAVA_HOME%/bin
4. 打开命令行控制台，执行java -version命令检查JDK安装成功

### 安装和配置Maven

1. 下载并安装Apache Maven

2. 配置环境变量M2_HOME，指向Maven的安装根文件夹

3. 配置环境变量PATH，增加%M2_HOME%/bin

4. 在maven的settings.xml文件profiles标签中，增加以下内容

   ```xml
   <profiles>
     ......
     <profile>
       <id>cplm-private-repo</id>
       <activation>
         <activeByDefault>true</activeByDefault>
       </activation>
       <repositories>
         <repository>
           <id>cplm-releases</id>
           <url>http://packages.corilead.com/artifactory/cplm-releases</url>
         </repository>
         <repository>
           <id>cplm-snapshots</id>
           <url>http://packages.corilead.com/artifactory/cplm-snapshots</url>
         </repository>
       </repositories>
     </profile>
     ......
   </profiles>
   ```

### 安装和配置IDEA

1. 下载并按照默认配置安装IDEA(https://www.jetbrains.com/idea/download/)
2. 安装Lombok、Alibaba Coding Guidelines、google-java-format、Maven Helper、EasyYapi插件
3. IntelliJ IDEA 设置要求
   1. 选择Build, Execution, Deployment > Build Tools > Maven > Importing，选中Import Maven projects automatically
   2. 选择Build, Execution, Deployment > Compiler，选中Build project automatically
   3. 选择Other Settings > google-java-format Settings，选中Enable google-java-format
   4. 选择Editor > Code Style，导入IntelliJ Java Google Style file文件，并确认Schema选中GoogleStyle
4.  IDEA的git commit窗口中，Before Commit区域选中Alibaba Code Guidelines、Optimize imports和Run Git hooks，不要勾选reformat code(https://github.com/google/google-java-format/issues/228)

## C++开发环境配置



## C#开发环境配置


