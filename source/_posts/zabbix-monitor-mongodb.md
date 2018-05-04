---
title: zabbix监控mongodb
tags:
  - mongodb
  - zabbix
id: 739
categories:
  - Mongo
  - Zabbix
date: 2015-12-30 14:18:02
---

MongoDB（来自于英文单词“Humongous”，中文含义为“庞大”）是可以应用于各种规模的企业、各个行业以及各类应用程序的开源数据库。作为一个适用于敏捷开发的数据库，MongoDB的数据模式可以随着应用程序的发展而灵活地更新。与此同时，它也为开发人员 提供了传统数据库的功能：二级索引，完整的查询系统以及严格一致性等等。 MongoDB能够使企业更加具有敏捷性和可扩展性，各种规模的企业都可以通过使用MongoDB来创建新的应用，提高与客户之间的工作效率，加快产品上市时间，以及降低企业成本.

<!-- more -->
### 1\. 下载模版

<pre class="lang:sh decode:true">cenhuqing@cenhuqingdeMBP ~$ wget http://mongoing.com/wp-content/uploads/2014/11/Mongodb_eshu.txt

模版名后缀改成xml，导入web模版

监控的参数有如下：
connections
BackgroundFlush
curosor
oplogstoragetime
pagefaults
queue
index
mem
network
Opcounters</pre>

### 2，配置客户端

<pre class="lang:sh decode:true">[root@zhishi ~]# vim /usr/local/etc/zabbix_agentd.conf
Include=/usr/local/etc/zabbix.agentd.conf.d/*.conf

取消该注释
不取消也可以放在配置文件中。不过为了方便以后添加更多的参数所以创建文件</pre>

### 3.配置文件中添加参数

<span style="color: #ff0000;">注意：mongo带认证需要添加认证用户名和密码</span>
<pre class="lang:sh decode:true">[root@zhishi ~]# vim /usr/local/etc/zabbix_agentd.conf.d/monitor_mongodb.conf
UserParameter=mongo.service,ps -ef | grep mongo |grep -v grep |wc -l
UserParameter=mongo.mem_resident,echo "db.serverStatus().mem"| mongo -u root -p passwd admin|grep resident | cut -d ":" -f 2 |cut -d "," -f 1| cut -d " " -f 2
UserParameter=mongo.mem_virtual,echo "db.serverStatus().mem"| mongo -u root -p passwd admin|grep virtual | cut -d ":" -f 2 |cut -d "," -f 1| cut -d " " -f 2
UserParameter=mongo.mem_mapped,echo "db.serverStatus().mem"| mongo -u root -p passwd admin|grep '\bmapped\b' | cut -d ":" -f 2 |cut -d "," -f 1| cut -d " " -f 2
UserParameter=mongo.network[*],echo "db.serverStatus().network"|mongo -u root -p passwd admin| grep $1 | cut -d ":" -f 2 |cut -d "," -f1 |cut -d " " -f 2
UserParameter=mongo.index[*],echo "db.serverStatus().indexCounters"|mongo -u root -p passwd admin| grep $1| cut -d ":" -f 2 |cut -d "," -f1 |cut -d " " -f 2
UserParameter=mongo.connection_current,echo "db.serverStatus().connections"| mongo -u root -p passwd admin| grep current|cut -d ":" -f 2|cut -d "," -f 1|cut -d " " -f 2
UserParameter=mongo.connection_available,echo "db.serverStatus().connections"| mongo -u root -p passwd admin| grep current| cut -d ":" -f 3|cut -d "," -f 1 |cut -d " " -f 2
UserParameter=mongo.opcounters[*],echo "db.serverStatus().opcounters" |mongo -u root -p passwd admin| grep $1|cut -d ":" -f 2|cut -d "," -f 1 |cut -d " " -f 2
UserParameter=mongo.rpstatus,echo "rs.status()"| mongo -u root -p passwd admin| grep myState| cut -d ":" -f 2| cut -d "," -f 1 |cut -d " " -f 2
UserParameter=mongo.queue_write,echo "db.serverStatus().globalLock.currentQueue.writers"|mongo -u root -p passwd admin|sed -n 3p
UserParameter=mongo.queue_reader,echo "db.serverStatus().globalLock.currentQueue.readers"|mongo -u root -p passwd admin|sed -n 3p
UserParameter=mongo.backgroundFlush,echo "db.serverStatus().backgroundFlushing.last_ms" |mongo -u root -p passwd admin|sed -n 3p
UserParameter=mongo.curosor_Totalopen,echo "db.serverStatus().cursors.totalOpen" |mongo -u root -p passwd admin|sed -n 3p
UserParameter=mongo.curospr_timedOu,echo "db.serverStatus().cursors.timedOut" |mongo -u root -p passwd admin|sed -n 3p
UserParameter=mongo.pagefaults,echo "db.serverStatus().extra_info.page_faults" |mongo -u root -p passwd admin|sed -n 3p
UserParameter=mongo.oplog_storetime,echo "db.printReplicationInfo()"|mongo -u root -p passwd admin|sed -n 4p|cut -d "(" -f 2|cut -d "h" -f 1</pre>

### 4.测试

4.1 客户端测试
<pre class="lang:sh decode:true ">[root@zhishi ~]#  echo "db.serverStatus().mem"| mongo -u root -p passwd admin|grep resident | cut -d ":" -f 2 |cut -d "," -f 1| cut -d " " -f 2
93</pre>
4.2 监控端测试
<pre class="lang:sh decode:true ">[root@monitor ~]#  zabbix_get -s 10.168.210.56 -k mongo.mem_resident
93</pre>

### 5.zabbix配置

![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151230-0@2x1.png)![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151230-1@2x1.png)![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151230-2@2x1.png)![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151230-3@2x1.png)

&nbsp;

&nbsp;
