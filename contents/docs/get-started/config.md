---
title: "配置中心参数"
sidebar: Docs
showTitle: true
---

## DataSource配置
### Oracle
```
spring.jpa.database-platform=org.hibernate.dialect.Oracle10gDialect

spring.datasource.driver-class-name=oracle.jdbc.driver.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@localhost:1521:cplm
spring.datasource.username=<username>
spring.datasource.password=<name>
```

### MySQL
```
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect

spring.datasource.driver-class-name=dm.jdbc.driver.DmDriver
spring.datasource.url=jdbc:mysql://localhost:3306/cplm?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=<username>
spring.datasource.password=<name>
```

### 达梦
```
spring.jpa.database-platform=org.hibernate.dialect.DmDialect

spring.datasource.driver-class-name=dm.jdbc.driver.DmDriver
spring.datasource.url=jdbc:dm://localhost:5236
spring.datasource.username=<username>
spring.datasource.password=<name>
```
