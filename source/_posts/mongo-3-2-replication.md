---
title: mongo-3.2主从配置
tags:
  - mongo-replcation
  - mongo主从
id: 864
categories:
  - DB
  - Linux
  - Mongo
date: 2017-01-04 16:08:24
---

<div>mongodb的复制使用的oplog,类似于mysql复制的binlog,不同的是oplog是保存在local数据库中的.</div>
<div>需要合理的设置oplog的大小,如果此大小没有设置那么mongodb将会使用可用空间的5%来存放oplog.官方建议64位系统至少分配1G大小.</div>
<div>当slave端落后太多master端的时候,复制会终止,此时需要管理员手工来重启mongodb然后使用resync来重新同步.</div>
<div>此外你可以设置autoresync参数,当复制终止10秒后mongodb会自动重启复制,slave端会每隔10分钟自动重新同步一次.</div>
<div>**注意官方现在强烈不建议使用master-slave复制模式,建议使用replica sets复制.**</div>
<!-- more -->
### 参数介绍

这里介绍的mongodb的主从复制,并不是复制集replica sets,复制的参数如下:
<pre class="lang:sh decode:true ">Replication options:
  --oplogSize arg                       操作日志大小,单位M

Master/slave options (old; use replica sets instead):
  --master                              指定角色为master mode
  --slave                               指定角色为slave mode
  --source arg                          当角色为slave的时候使用,格式为:&lt;server:port&gt;
  --only arg                            当角色为slave的时候使用,指定单独同步的数据库,默认为同步所有数据库.
  --slavedelay arg                      指定一个应用日志的延时,单位秒
  --autoresync</pre>

### 创建mongo仓库

<pre class="lang:sh decode:true ">vim /etc/yum.repos.d/mongodb-org-3.2.repo
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc</pre>

### 主从服务器配置

<pre class="lang:sh decode:true">#安装
yum install -y mongodb-org
#修改配置
egrep -v '^$|^#' /etc/mongod.conf
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
storage:
  dbPath: /var/lib/mongo
  journal:
    enabled: true
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/mongod.pid  # location of pidfile
net:
  port: 27017
  bindIp: 0.0.0.0  # Listen to local interface only, comment to listen on all interfaces.
security:
  authorization: enabled
</pre>

### 配置keyFile文件

（[官网介绍](https://docs.mongodb.com/v3.2/tutorial/enforce-keyfile-access-control-in-existing-replica-set/)）密钥文件的内容作为共享密码的成员复制集。密钥文件的内容必须相同副本集的所有成员。你可以使用任何方法生成一个密钥文件选择。密钥文件的内容必须是6 - 1024个字符长。
<pre class="lang:sh decode:true ">openssl rand -base64 512 &gt;&gt; /var/lib/mongo/mongo.key
chmod 600 /var/lib/mongo/mongo.key</pre>

### 启动服务

<pre class="lang:sh decode:true">#主服务器启动
mongod --master -f /etc/mongod.conf --keyFile /var/lib/mongo/mongo.key
#从服务器启动
mongod --slave --source master_ip:27017 -f /etc/mongod.conf --keyFile /var/lib/mongo/mongo.key</pre>

### 测试

主服务器创建账号
<pre class="lang:sh decode:true ">#!/bin/bash
mongo_connect="mongo 127.0.0.1/admin"  
cmd_use_admin="db = db.getSiblingDB('admin');"  
cmd_create_user="db.createUser({\"user\":\"sa\", \"pwd\":\"123456\", \"roles\":[\"root\"]});"  
echo $cmd_use_admin &gt; dbcmd.js  
echo $cmd_create_user &gt;&gt; dbcmd.js  
execute="$mongo_connect dbcmd.js"  
echo "#!/bin/sh" &gt; createDBUser.sh  
echo $execute &gt;&gt; createDBUser.sh  
sh createDBUser.sh &amp;&amp; rm -f createDBUser.sh</pre>
主库插入一条数据
<pre class="lang:sh decode:true ">use test
db.xxoo.save({xx:00});</pre>
从库查看是否同步
<pre class="lang:sh decode:true ">use test
db.test.find()</pre>

### 主库宕机如何将从库切为主库

###### 方式一

*   停止从库
`kill -2 PID`
*   删除从数据目录中的 local.*
`rm -rf /data/mongodb/data/db/local.*`
*   以 --master 模式启动从库 (注意修改原有端口)
`mongod --master -f /etc/mongod.master.conf`

###### 方式二

*   备份从库
*   重建主库，导入新数据
参考：https://docs.mongodb.com/v3.2/replication/

https://blog.imdst.com/mongodb-yi-di-zhu-cong-tong-bu-pei-zhi/

http://blog.csdn.net/su377486/article/details/51599255
