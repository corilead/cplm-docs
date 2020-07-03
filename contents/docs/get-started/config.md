---
title: "开发环境配置"
sidebar: Docs
showTitle: true
---
## DataSource配置
### 达梦数据库
```
spring.jpa.database-platform=org.hibernate.dialect.DmDialect

spring.datasource.driver-class-name=dm.jdbc.driver.DmDriver
spring.datasource.url=jdbc:dm://localhost:5236
spring.datasource.username=<username>
spring.datasource.password=<name>
```
