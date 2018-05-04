---
title: 安装mongodb-enterprise-2.6
tags:
  - mongodb
id: 714
categories:
  - Mongo
date: 2015-12-08 11:38:38
---

MongoDB社区版本和企业版本差异主要体现在安全认证、系统认证等方面，具体信息参考下表：
这里使用的是企业版，版本是2.6，新版3.2还在开发中。。。
<!-- more -->
### 1.添加仓库

<pre class="lang:sh decode:true ">[root@VM-248 ~]# vim /etc/yum.repos.d/mongodb-enterprise.repo
[mongodb-enterprise-2.6]
name=MongoDB Enterprise 2.6 Repository
baseurl=https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/2.6/$basearch/
gpgcheck=0
enabled=1</pre>

### 2.yum安装

<pre class="lang:sh decode:true ">[root@VM-248 ~]# yum install -y mongodb-enterprise
[root@VM-248 ~]# rpm -qa |grep mongodb
mongodb-enterprise-server-2.6.11-1.el6.x86_64
mongodb-enterprise-tools-2.6.11-1.el6.x86_64
mongodb-enterprise-2.6.11-1.el6.x86_64
mongodb-enterprise-sh-2.6.11-1.el6.x86_64
mongodb-enterprise-mongos-2.6.11-1.el6.x86_64</pre>

### 3.修改配置

<pre class="lang:sh decode:true ">[root@VM-248 ~]# egrep -v '^$|^#' /etc/mongod.conf
logpath=/var/log/mongodb/mongod.log
logappend=true
fork=true
dbpath=/var/lib/mongo
pidfilepath=/var/run/mongodb/mongod.pid
bind_ip=0.0.0.0
auth=true</pre>

### 4.启动服务

<pre class="lang:sh decode:true ">[root@VM-248 ~]# /etc/init.d/mongod start
[root@VM-248 ~]# chkconfig mongod  on</pre>

### 5.添加密码

<pre class="lang:sh decode:true ">[root@VM-248 ~]# mongo
MongoDB sh version: 2.6.11
connecting to: test
&gt; use admin
switched to db admin
&gt; db.addUser('root','password')
WARNING: The 'addUser' sh helper is DEPRECATED. Please use 'createUser' instead
Successfully added user: { "user" : "root", "roles" : [ "root" ] }
&gt; db.system.users.find()
{ "_id" : "admin.root", "user" : "root", "db" : "admin", "credentials" : { "MONGODB-CR" : "29e87d0a8716c4ae20efbcdd9d252f5b" }, "roles" : [ { "role" : "root", "db" : "admin" } ] }
&gt; exit
bye</pre>

### 6.删除密码

<pre class="lang:sh decode:true ">&gt; db.system.users.find()
{ "_id" : "test.root", "user" : "root", "db" : "test", "credentials" : { "MONGODB-CR" : "29e87d0a8716c4ae20efbcdd9d252f5b" }, "roles" : [ { "role" : "dbOwner", "db" : "test" } ] }
&gt; db.system.users.remove({user:"root"})
WriteResult({ "nRemoved" : 1 })
&gt; db.system.users.find()
&gt; exit
bye</pre>

### 7.远程连接

<pre class="lang:sh decode:true ">cenhuqing@cenhuqingdeMacBook-Pro ~$mongo vm248/admin -u root -p password
MongoDB sh version: 3.0.4
connecting to: vm248/admin
&gt; show dbs;
admin  0.078GB
local  0.078GB
&gt; exit
bye</pre>
参考文章：https://docs.mongodb.org/manual/tutorial/install-mongodb-enterprise-on-red-hat/
