---
title: 搭建ELK(Logstash+Elasticsearch+Kibana)日志分析系统
tags:
  - elasticsearch
  - kibana
  - logstash
id: 666
categories:
  - Elasticsearch
  - Kibana
  - Logstash
date: 2015-10-29 17:20:44
---

Logstash：负责日志的收集，处理和储存
Elasticsearch：负责日志检索和分析
Kibana：负责日志的可视化
<!-- more -->
### 1\. 系统环境：

<pre class="lang:sh decode:true ">[root@monitor ~]# cat /etc/redhat-release 
CentOS release 6.6 (Final)</pre>
检测主机名
<pre class="lang:sh decode:true ">[root@monitor ~]# hostname -f
monitor</pre>
安装java
<pre class="lang:sh decode:true ">[root@monitor ~]# yum install java-1.8.0-openjdk
查看java版本
[root@monitor ~]# java -version
openjdk version "1.8.0_65"
OpenJDK Runtime Environment (build 1.8.0_65-b17)
OpenJDK 64-Bit Server VM (build 25.65-b01, mixed mode)</pre>

### 2. 安装logstash

yum安装
<pre class="lang:sh decode:true ">[root@monitor ~]# yum install https://download.elastic.co/logstash/logstash/packages/centos/logstash-1.5.4-1.noarch.rpm</pre>
创建证书
<pre class="lang:sh decode:true ">[root@monitor ~]# cd /etc/pki/tls
[root@monitor tls]# openssl req -subj '/CN=monitor/' -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
Generating a 2048 bit RSA private key
...................................................+++
...........................................................................................................+++
writing new private key to 'private/logstash-forwarder.key'
-----</pre>
同步证书到客户端
<pre class="lang:sh decode:true ">[root@monitor tls]# scp /etc/pki/tls/certs/logstash-forwarder.crt root@baicare:/etc/pki/tls/certs/</pre>
创建patterns目录，并编写nginx-grok
<pre class="lang:sh decode:true ">[root@monitor tls]# mkdir /opt/logstash/patterns
[root@monitor tls]# vim /opt/logstash/patterns/nginx
NGUSERNAME [a-zA-Z\.\@\-\+_%]+
NGUSER %{NGUSERNAME}
NGINXACCESS %{IPORHOST:slb_addr} - - \[%{HTTPDATE:time_local}\] "%{WORD:method} %{URIPATH:path}(?:%{URIPARAM:param})? HTTP/%{NUMBER:httpversion}" %{INT:status} %{INT:body_bytes_sent} %{QS:http_referer} %{QS:http_user_agent} "%{IPORHOST:remote_addr}"</pre>
编辑配置文件
<pre class="lang:sh decode:true">root@monitor tls]# vim /etc/logstash/conf.d/logstash.conf
input {
  lumberjack {
    port =&gt; 5000
    type =&gt; "logs"
    ssl_certificate =&gt; "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key =&gt; "/etc/pki/tls/private/logstash-forwarder.key"
  }
}

filter {
  if [type] == "syslog" {
    grok {
      match =&gt; { "message" =&gt; "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field =&gt; [ "received_at", "%{@timestamp}" ]
      add_field =&gt; [ "received_from", "%{host}" ]
    }
    syslog_pri { }
    date {
      match =&gt; [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
  if [type] == "nginx" {
    grok {
       match =&gt; { "message" =&gt; "%{NGINXACCESS}" }
    }
  }
}

output {
  elasticsearch { host =&gt; localhost }
  stdout { codec =&gt; rubydebug }
</pre>
启动服务
<pre class="lang:sh decode:true ">[root@monitor ~]# /etc/init.d/logstash start
[root@monitor ~]# chkconfig logstash on</pre>

### 3. 安装elasticsearch

yum安装
<pre class="lang:sh decode:true ">[root@monitor ~]# yum install https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.1.noarch.rpm</pre>
添加到开机启动，并启动服务
<pre class="lang:sh decode:true">[root@monitor ~]# chkconfig --add elasticsearch
[root@monitor ~]# service elasticsearch start
Starting elasticsearch:                                    [  OK  ]
[root@monitor ~]# netstat -lutnp |grep java
tcp        0      0 0.0.0.0:9300                0.0.0.0:*                   LISTEN      26898/java          
tcp        0      0 0.0.0.0:9200                0.0.0.0:*                   LISTEN      26898/java          
udp        0      0 0.0.0.0:54328               0.0.0.0:*                               26898/java          
</pre>
测试是否能正常访问
<pre class="lang:sh decode:true ">[root@monitor ~]# curl -X GET http://localhost:9200
{
  "status" : 200,
  "name" : "Conquistador",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "1.7.1",
    "build_hash" : "b88f43fc40b0bcd7f173a1f9ee2e97816de80b19",
    "build_timestamp" : "2015-07-29T09:54:16Z",
    "build_snapshot" : false,
    "lucene_version" : "4.10.4"
  },
  "tagline" : "You Know, for Search"
}</pre>

### 4.安装kibana

下载源码包
<pre class="lang:sh decode:true ">[root@monitor ~]# wget https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz</pre>
解压并重命名
<pre class="lang:sh decode:true ">[root@monitor ~]# tar xf kibana-4.1.1-linux-x64.tar.gz -C /usr/local/
[root@monitor ~]# mv /usr/local/kibana-4.1.1-linux-x64 /usr/local/kibana</pre>
编写启动脚本
<pre class="lang:sh decode:true">[root@monitor ~]# vim /etc/rc.d/init.d/kibana
#!/bin/bash
# BEGIN INIT INFO
# Provides:          kibana
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Runs kibana daemon
# Description: Runs the kibana daemon as a non-root user
### END INIT INFO

# Process name
NAME=kibana
DESC="Kibana4"
PROG="/etc/init.d/kibana"

# Configure location of Kibana bin
KIBANA_BIN=/usr/local/kibana/bin

# PID Info
PID_FOLDER=/var/run/kibana/
PID_FILE=/var/run/kibana/$NAME.pid
LOCK_FILE=/var/lock/subsys/$NAME
PATH=/bin:/usr/bin:/sbin:/usr/sbin:$KIBANA_BIN
DAEMON=$KIBANA_BIN/$NAME

# Configure User to run daemon process
DAEMON_USER=root
# Configure logging location
KIBANA_LOG=/var/log/kibana.log

# Begin Script
RETVAL=0

if [ `id -u` -ne 0 ]; then
        echo "You need root privileges to run this script"
        exit 1
fi

# Function library
. /etc/init.d/functions

start() {
        echo -n "Starting $DESC : "

pid=`pidofproc -p $PID_FILE kibana`
        if [ -n "$pid" ] ; then
                echo "Already running."
                exit 0
        else
        # Start Daemon
if [ ! -d "$PID_FOLDER" ] ; then
                        mkdir $PID_FOLDER
                fi
daemon --user=$DAEMON_USER --pidfile=$PID_FILE $DAEMON 1&gt;"$KIBANA_LOG" 2&gt;&amp;1 &amp;
                sleep 2
                pidofproc node &gt; $PID_FILE
                RETVAL=$?
                [[ $? -eq 0 ]] &amp;&amp; success || failure
echo
                [ $RETVAL = 0 ] &amp;&amp; touch $LOCK_FILE
                return $RETVAL
        fi
}

reload()
{
    echo "Reload command is not implemented for this service."
    return $RETVAL
}

stop() {
        echo -n "Stopping $DESC : "
        killproc -p $PID_FILE $DAEMON
        RETVAL=$?
echo
        [ $RETVAL = 0 ] &amp;&amp; rm -f $PID_FILE $LOCK_FILE
}

case "$1" in
  start)
        start
;;
  stop)
        stop
        ;;
  status)
        status -p $PID_FILE $DAEMON
        RETVAL=$?
        ;;
  restart)
        stop
        start
        ;;
  reload)
reload
;;
  *)
# Invalid Arguments, print the following message.
        echo "Usage: $0 {start|stop|status|restart}" &gt;&amp;2
exit 2
        ;;
esac</pre>
启动服务
<pre class="lang:sh decode:true ">[root@monitor local]# chmod +x /etc/rc.d/init.d/kibana
[root@monitor local]# /etc/init.d/kibana start
Starting Kibana4 :                                         [确定]
[root@monitor local]# chkconfig kibana on

[root@monitor local]# netstat -lutnp |grep java
tcp        0      0 0.0.0.0:9300                0.0.0.0:*                   LISTEN      26898/java          
tcp        0      0 0.0.0.0:9200                0.0.0.0:*                   LISTEN      26898/java          
udp        0      0 0.0.0.0:54328               0.0.0.0:*                               26898/java   
</pre>

### 5\. 配置nginx

编辑配置文件
<pre class="lang:sh decode:true">[root@monitor vhost]# vim kibana.conf
server {
     listen 80;
     server_name kibana.baicare.com;

     location / {
         proxy_pass http://127.0.0.1:5601;
         root /usr/local/kibana/src;
         auth_basic "Restricted";
         auth_basic_user_file /usr/local/nginx/conf/kibana.htpasswd;
     }
}</pre>
创建登录账号密码
<pre class="lang:sh decode:true">[root@monitor geoip]# htpasswd -c /usr/local/nginx/conf/kibana.htpasswd charlie
New password: 
Re-type new password: 
Adding password for user charlie</pre>
启动服务
<pre class="lang:sh decode:true ">[root@monitor vhost]# nginx -t
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
[root@monitor vhost]# nginx -s reload</pre>

#### <span style="color: #800000;">以上是服务器端配置，下面是客户端配置</span>

&nbsp;

### 6\. 安装logstash-forwarder

yum安装logstash-forwarder
<pre class="lang:sh decode:true">[root@baicare ~]# yum install -y https://download.elastic.co/logstash-forwarder/binaries/logstash-forwarder-0.4.0-1.x86_64.rpm
[root@baicare ~]# cp /etc/logstash-forwarder.conf /etc/logstash-forwarder.conf.bak</pre>
编辑配置
<pre class="lang:sh decode:true ">{
  "network": {
    "servers": [ "monitor:5000" ],

    "ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt",

    "timeout": 15
  },

  "files": [
    {
      "paths": [
        "/var/log/messages",
        "/var/log/secure"
      ],
      "fields": { "type": "syslog" }
    }, {
      "paths": [
        "/home/wwwlogs/access_nginx.log"
      ],
      "fields": { "type": "nginx" }
    }
  ]
}</pre>
启动服务
<pre class="lang:sh decode:true ">[root@baicare src]# /etc/init.d/logstash-forwarder start
logstash-forwarder started</pre>
然后打开浏览器，访问服务器（域名解析提前做好）

### 7\. 配置索引模式

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151029-2@2x.png)

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151029-3@2x.png)

&nbsp;

参考文章：

ELKstack 中文指南 - http://kibana.logstash.es/
三斗室 - http://chenlinux.com/
elastic - https://www.elastic.co/guide
LTMP索引 - http://wsgzao.github.io/index/#LTMP

&nbsp;
