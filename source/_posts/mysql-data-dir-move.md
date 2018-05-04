---
title: mysql数据目录迁移
tags:
  - mysql
id: 689
categories:
  - Mysql
date: 2015-11-16 11:20:41
---

早上来看到磁盘容量不足而报警，看下目录数据，决定迁移mysql数据到另外空闲磁盘上。

mysql的数据目录位置是/data/，需要迁移到/app/目录下

实现步骤：
<!-- more -->

### 1\. 停止mysql服务

<pre class="lang:sh decode:true ">[root@monitor ~]# /etc/init.d/mysqld stop
Shutting down MySQL.... SUCCESS!</pre>

### 2\. 移动数据

<pre class="lang:sh decode:true ">[root@monitor ~]# mv /data/mysql/ /app/data/</pre>

### 3\. 修改主配置文件

<pre class="lang:sh decode:true">[root@monitor ~]# vim /etc/my.cnf
[mysqld]
basedir = /usr/local/mysql
datadir = /app/data/mysql
pid-file = /app/data/mysql/mysql.pid</pre>

### 4\. 启动服务

<pre class="lang:sh decode:true ">[root@monitor ~]# /etc/init.d/mysqld start
Starting MySQL. ERROR! The server quit without updating PID file (/app/data/mysql/mysql.pid).</pre>
启动报错，解决办法，开启错误日志
<pre class="lang:sh decode:true ">[root@monitor ~]# vim /etc/my.cnf 
log_error = /app/data/mysql/mysql-error.log
slow_query_log_file = /app/data/mysql/mysql-slow.log
</pre>
由于日志路径未修改，导致出错。所以改完启动就可以了。
<pre class="lang:sh decode:true ">[root@monitor ~]# /etc/init.d/mysqld start
Starting MySQL... SUCCESS!</pre>
&nbsp;
