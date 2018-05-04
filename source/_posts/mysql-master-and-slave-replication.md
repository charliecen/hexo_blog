---
title: MySQL 主从复制（内外网）
date: 2017-06-30 06:04:37
tags:
  - replication
  - mysql主从
categories:
  - Mysql
---

![file](http://7xlxn7.com1.z0.glb.clouddn.com/ll7-S3ymCwBcfZ2a9rCCykTfm2Dk.jpeg)

+  master服务器将数据的改变记录二进制日志，当master上的数据发生改变时，则将其改变写入二进制日志中.
+  salve服务器会在一定时间间隔内对master二进制日志进行探测其是否发生改变，如果发生改变，则开始一个I/OThread请求master二进制事件，同时master节点为每个I/O线程启动一个dump线程，用于向其发送二进制事件，并保存至slave节点本地的中继日志中.
+  slave节点将启动SQL线程从中继日志中读取二进制日志，在本地重放，使得其数据和master节点的保持一致，最后I/OThread和SQLThread将进入睡眠状态，等待下一次被唤醒。

<!-- more -->

### master 库操作

>注意： `master`与`slave`库的版本需要一致

#### master 配置

```sh
$ vim /etc/my.cnf
[mysqld]
## 设置server_id，一般设置为IP,注意要唯一
server_id=146
### 复制过滤：也就是指定哪个数据库不用同步（mysql库一般不同步）
binlog-ignore-db=mysql
### 开启二进制日志功能，可以随便取，最好有含义（关键就是这里了）
log-bin=mysql-bin
### 为每个session 分配的内存，在事务过程中用来存储二进制日志的缓存
binlog_cache_size=1M
### 主从复制的格式（mixed,statement,row，默认格式是statement）
binlog_format=mixed
### 二进制日志自动删除/过期的天数。默认值为0，表示不自动删除。
expire_logs_days=7
### 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
### 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062
```

#### master启动服务

```sh
$ /etc/init.d/mysqld restart
```

#### 锁表导数据

```sql
mysql> flush  tables  with  read  lock;
```

#### 导出数据拷贝

```sh
$ mysqldump -uuser -ppassword dbname > mysql_bak.sql
$ scp mysql_bak.sql root@server_ip:/data/
```

#### 记录pos并解锁

```sql
mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000003 | 29880250 |              | mysql            |
+------------------+----------+--------------+------------------+

mysql> unlock tables;
```

#### 授权

```sql
mysql> grant replication slave on *.* to 'rep'@'%' identified by '123456';
mysql> flush privileges; 
```


### slave库操作

#### 安装

```sh
$ yum install mysql-server -y
```

#### 配置文件

```sh
$ vim /etc/my.cnf
## 设置server_id，一般设置为IP,注意要唯一
server_id=202
### 复制过滤：也就是指定哪个数据库不用同步（mysql库一般不同步）
binlog-ignore-db=mysql
### 开启二进制日志功能，以备Slave作为其它Slave的Master时使用
log-bin=mysql-bin
### 为每个session 分配的内存，在事务过程中用来存储二进制日志的缓存
binlog_cache_size=1M
### 主从复制的格式（mixed,statement,row，默认格式是statement）
binlog_format=mixed
### 二进制日志自动删除/过期的天数。默认值为0，表示不自动删除。
expire_logs_days=7
### 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
### 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062
### relay_log配置中继日志
relay_log=mysql-relay-bin
### log_slave_updates表示slave将复制事件写进自己的二进制日志
log_slave_updates=1
### 防止改变数据(除了特殊的线程)
#read_only=1
```

####  启动服务

```sh
$ /etc/init.d/mysqld start
```

#### 创建密码并导入备份数据

```sh
$ mysqladmin -uroot -p password '123456'
$ mysql -uroot -p123456 < mysql_bak.sql
```

####  连主库

```sql
mysql> CHANGE MASTER TO MASTER_HOST='MASTER_IP',MASTER_USER='rep',MASTER_PASSWORD='123456',MASTER_LOG_FILE='mysql-bin.000003',MASTER_LOG_POS=29880250;

mysql> start slave;
```
#### 查看salve状态

```sql
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 118.194.48.246
                  Master_User: rep
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 41113925
               Relay_Log_File: mysql-relay-bin.000007
                Relay_Log_Pos: 11233926
        Relay_Master_Log_File: mysql-bin.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 41113925
              Relay_Log_Space: 12941554
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
1 row in set (0.00 sec)
```

>注意：`Slave_IO_Running: Yes, Slave_SQL_Running: Yes`这两个参数为`Yes`表示正常。

========
### 问题1:

#### 问题描述
由于master库在外网，slave库在内网，当master日志发生变化时，master与slave的连接有时会断开，导致外网的master的binlog无法发送给内网的slave.只有在slave发起连接时才能建立连接，保持日志传输。

#### master库状态
此时正在连接中
![file](http://7xlxn7.com1.z0.glb.clouddn.com/lhfT7q8JOGAHKCa4D6iJ5QZO5Vbu.jpeg)

#### 解决办法
所以我在slave库上写了个脚本，判断master库的pos与slave库的pos是否一致，如果不一致就重启slave

```sh
#!/bin/bash

#主数据库配置
master_ip='118.xx.xxx.xxx'
master_mysql_port=3306
master_mysql_name='test1'
master_mysql_user='root'
master_mysql_password='123456'

#从数据库配置
slave_ip='192.168.150.202'
slave_mysql_user='root'
slave_mysql_password='123456'
slave_mysql_name='test2'

log='/var/log/slave_restart.log'
dat=`date +%F-%H:%M:%S`

#连接主库获取master pos
mysql -u$master_mysql_user -p$master_mysql_password -h $master_ip -P $master_mysql_port -e "use $master_mysql_name; show master status" > master_pos.txt
if [ $? -eq 0 ]
then
        master_pos=`awk '/^mysql-bin/{print $2}' master_pos.txt`
        mysql -u$slave_mysql_user -p$slave_mysql_password -h $slave_ip -e "use $slave_mysql_name; show slave status\G" > slave_pos.txt
        if [ $? -eq 0 ]
        then
                slave_pos=`awk '/Read_Master_Log_Pos/{print $2}' slave_pos.txt`
                if [ $master_pos != $slave_pos ]
                then
                        mysql -u$slave_mysql_user -p$slave_mysql_password -h $slave_ip -e "stop slave;start slave" && echo "$dat--->从库重启成功" >> $log || echo "$dat--->从库重启失败" >> $log
                fi
        fi
fi
```


#### 放入计划任务

```sh
$ crontab -e
#每五分钟检测从库的pos是否与主库一致，如不一致重启slave
*/5 * * * * /bin/bash /data/scripts/mysql_replication_slave_restart.sh
```

#### 查看日志

```sh
$ tailf /var/log/slave_restart.log
2017-06-29-17:20:01--->从库重启成功
2017-06-29-17:30:01--->从库重启成功
2017-06-29-17:35:01--->从库重启成功
2017-06-29-17:50:01--->从库重启成功
2017-06-29-17:55:01--->从库重启成功
2017-06-29-18:00:01--->从库重启成功
2017-06-29-18:05:01--->从库重启成功
2017-06-29-18:10:01--->从库重启成功
2017-06-29-18:15:01--->从库重启成功
2017-06-29-18:20:01--->从库重启成功
```

#### 查看master,slave的pos是否一致

```sql
mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000003 | 56780950 |              | mysql            |
+------------------+----------+--------------+------------------+
1 row in set (0.00 sec)

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 118.xx.xxx.xxx
                  Master_User: rep
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 56780950
               Relay_Log_File: mysql-relay-bin.000016
                Relay_Log_Pos: 441
        Relay_Master_Log_File: mysql-bin.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```