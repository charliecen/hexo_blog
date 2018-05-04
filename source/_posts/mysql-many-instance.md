---
title: mysql多实例
tags:
  - mysql
  - replication
id: 758
categories:
  - Mysql
date: 2016-09-06 16:37:37
---

需求：

mysql主从复制，主mysql版本为5.5，从mysql版本为5.7

主库不需要操作，只在从数据库上配置

由于需要同步18个数据库，由于主库的端口各不相同，从库同样要开启18个实例
<div>前面直接用脚本操作</div>
<!-- more -->
<pre class="lang:sh decode:true">#!/bin/bash

#多实例端口号
port="3306 3312 3307 3319 3308 3309 3311 3330 3320 3321 3326 3327 3333 3314 3318 3323 3317 3316 3307"

for i in $port
do
	#创建数据目录
        mkdir /data/$i/dbdata -p

        #修改权限
        chown mysql:mysql /data/$i -R

        #初始化数据库
        /usr/local/mysql/bin/mysqld --initialize-insecure --user="mysql" --basedir="/usr/local/mysql" --datadir="/data/$i/dbdata"

        #拷贝配置文件
        cp /opt/my.cnf /data/$i/

        #修改配置
        sed -i "s/3312/$i/g" /data/$i/my.cnf

        #启动
        mysqld_safe --defaults-file="/data/$i/my.cnf" &amp;

        #登录,第一次登录默认密码为空
        mysql -S /tmp/mysql$i.sock &lt;&lt; EOF

        #修改密码
        use mysql;
        set password = password('******');

        #授予权限
        grant all on *.* to root@'192.168.61.%' identified by '******';
        flush privileges;
        exit;
EOF

done</pre>
脚本注释：

#初始化，5.7版本废弃mysql_install_db命令，该用mysqld 来初始化，—initialize 参数来创建密码，默认保存在~/.mysql_secret 。 —initialize-insecure 参数创建空密码

主配置文件
<pre class="lang:sh decode:true ">[client]
port = 3312
socket = /tmp/mysql3312.sock
default-character-set = utf8mb4

[mysql]
prompt="MySQL [\d]&gt; "
no-auto-rehash

[mysqld]
port = 3370
socket = /tmp/mysql3312.sock

basedir = /usr/local/mysql
datadir = /data/3312/dbdata
pid-file = /data/3312/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 5

init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4

skip-name-resolve

log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7</pre>
查看服务
<pre class="lang:sh decode:true ">[root@host-192-168-150-202 ~]# netstat -lutnp |grep mysqld
tcp        0      0 0.0.0.0:3307                0.0.0.0:*                   LISTEN      28591/mysqld
tcp        0      0 0.0.0.0:3308                0.0.0.0:*                   LISTEN      30546/mysqld
tcp        0      0 0.0.0.0:3309                0.0.0.0:*                   LISTEN      31062/mysqld
tcp        0      0 0.0.0.0:3311                0.0.0.0:*                   LISTEN      31564/mysqld
tcp        0      0 0.0.0.0:3312                0.0.0.0:*                   LISTEN      27792/mysqld
tcp        0      0 0.0.0.0:3314                0.0.0.0:*                   LISTEN      2978/mysqld
tcp        0      0 0.0.0.0:3316                0.0.0.0:*                   LISTEN      5322/mysqld
tcp        0      0 0.0.0.0:3317                0.0.0.0:*                   LISTEN      4736/mysqld
tcp        0      0 0.0.0.0:3318                0.0.0.0:*                   LISTEN      3564/mysqld
tcp        0      0 0.0.0.0:3319                0.0.0.0:*                   LISTEN      11531/mysqld
tcp        0      0 0.0.0.0:3320                0.0.0.0:*                   LISTEN      32591/mysqld
tcp        0      0 0.0.0.0:3321                0.0.0.0:*                   LISTEN      661/mysqld
tcp        0      0 0.0.0.0:3323                0.0.0.0:*                   LISTEN      4150/mysqld
tcp        0      0 0.0.0.0:3326                0.0.0.0:*                   LISTEN      1229/mysqld
tcp        0      0 0.0.0.0:3327                0.0.0.0:*                   LISTEN      1774/mysqld
tcp        0      0 0.0.0.0:3330                0.0.0.0:*                   LISTEN      32066/mysqld
tcp        0      0 0.0.0.0:3333                0.0.0.0:*                   LISTEN      2392/mysqld
tcp        0      0 0.0.0.0:3370                0.0.0.0:*                   LISTEN      6497/mysqld
tcp        0      0 0.0.0.0:3306                0.0.0.0:*                   LISTEN      5923/mysqld</pre>
登录到主数据库上查看file,pos等信息，来配置从数据库
<pre class="lang:sh decode:true">#指定主服务器
mysql&gt; change master to master_host="192.168.101.22",master_port=3370,master_user="kfuser",master_password="kfpasswd",master_log_file="mysql-bin.000006",master_log_pos=246808818;
mysql&gt; start slave;
mysql&gt; show slave status\G
*************************** 1\. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.101.99
                  Master_User: ****
                  Master_Port: 3307
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000007
          Read_Master_Log_Pos: 326301199
               Relay_Log_File: host-192-168-150-202-relay-bin.000002
                Relay_Log_Pos: 164439916
        Relay_Master_Log_File: mysql-bin.000007
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes</pre>

* * *

错误1：
<pre class="lang:sh decode:true ">Last_Errno: 1032
Last_Error: Could not execute Update_rows_v1 event on table InfoServer_HS.ONLINENUMREALTIME; Can't find record in 'ONLINENUMREALTIME', Error_code: 1032; handler error HA_ERR_KEY_NOT_FOUND; the event's master log mysql-bin.000006, end_log_pos 246506088</pre>
造成1032错误的根本原因是主从数据库数据不一致,导致同步操作在从库上无法执行.

解决办法：
<pre class="lang:sh decode:true ">vim /etc/my.cnf
slave-skip-errors = 1032 #跳过这个错误</pre>
错误2:
<pre class="lang:sh decode:true ">Last_SQL_Errno: 1677
Last_SQL_Error: Column 5 of table 'InfoServer_HS.ONLINENUM20160906' cannot be converted from type 'varchar(100)' to type 'varchar(100)'</pre>
解决办法：
<pre class="lang:sh decode:true ">mysql&gt; stop slave;
mysql&gt; set global slave_type_conversions=ALL_NON_LOSSY;
mysql&gt; start slave;</pre>
&nbsp;
