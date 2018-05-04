---
title: zabbix监控logstash的java
tags:
  - JMX
  - logstash
  - zabbix-java-gateway
id: 691
categories:
  - Logstash
  - Zabbix
date: 2015-11-16 18:00:11
---

Logstash 是一个运行在 JVM 上的软件，也就意味着 JMX 这种对 JVM 的通用监控方式对 Logstash 也是一样有效果的。要给 Logstash 启用 JMX，需要修改 ./bin/logstash.lib.sh 中 $JAVA_OPTS 变量的定义，或者在运行时设置 LS_JAVA_OPTS 环境变量。
<!-- more -->
在 ./bin/logstash.lib.sh 第 34 行 JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true" 下，添加如下几行：
<pre class="lang:sh decode:true ">[root@monitor logstash]# vim bin/logstash.lib.sh
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=9010"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.local.only=false"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false"</pre>
<div>重启 logstash 服务，JMX 配置即可生效。</div>
<div>有 JMX 以后，我们可以通过 jconsole 界面查看，也可以通过 zabbix 等监控系统做长期监控。甚至 logstash 自己也有插件 logstash-input-jmx 来读取远程 JMX 数据。</div>
<div></div>
<div>注意，zabbix-server 本身并不直接对 JMX 发起请求，而是单独有一个 Java Gateway 作为中间代理层角色。zabbix-server 的 java poller 连接 zabbix-java-gateway，由 zabbix-java-gateway 去获取远程 JMX 信息。所以，在 zabbix-web 配置之前，需要先配置 zabbix server 相关进程和设置：</div>
<div></div>

### 1\. 安装zabbix-java-gateway

<div>
<pre class="lang:sh decode:true">[root@monitor logstash]# yum install http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-java-gateway-2.4.7-1.el6.x86_64.rpm</pre>

### 2\. 修改zabbix_server配置文件

<pre class="lang:sh decode:true ">[root@monitor logstash]# vim /usr/local/etc/zabbix_server.conf
JavaGateway=127.0.0.1
JavaGatewayPort=10052
StartJavaPollers=5</pre>

### 3\. 启动zabbix-jtva-gateway服务，重启logstash服务

<pre class="lang:sh decode:true ">[root@monitor logstash]# /etc/init.d/zabbix-java-gateway start
[root@monitor logstash]# /etc/init.d/logstash restart</pre>
<div>查看JMX监控端口</div>
<div>
<pre class="lang:sh decode:true ">[root@monitor logstash]# netstat -lutnp |grep 9010
tcp        0      0 0.0.0.0:9010                0.0.0.0:*                   LISTEN      11842/java</pre>

### 4\. 配置zabbix

##### 4.1 选择监控JMX的主机

![](http://blog.cenhq.com/wp-content/uploads/2015/11/QQ20151116-0@2x.png)![](http://blog.cenhq.com/wp-content/uploads/2015/11/QQ20151116-1@2x.png)

##### 4.2 添加JMX

![](http://blog.cenhq.com/wp-content/uploads/2015/11/QQ20151116-2@2x.png)

##### 4.3 添加项目

![](http://blog.cenhq.com/wp-content/uploads/2015/11/QQ20151116-4@2x.png)![](http://blog.cenhq.com/wp-content/uploads/2015/11/QQ20151116-5@2x.png)

##### 4.4 创建图形

![](http://blog.cenhq.com/wp-content/uploads/2015/11/QQ20151116-6@2x.png)![](http://blog.cenhq.com/wp-content/uploads/2015/11/QQ20151116-7@2x.png)![](http://blog.cenhq.com/wp-content/uploads/2015/11/QQ20151116-8@2x.png)

</div>

* * *

<span style="color: #ff0000;">错误如下：</span>

</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/11/1.jpg)</div>
<div>
<div>貌似无法连接java的9010端口，所以手动检测下</div>
<div>检测需要cmdline-jmxclient-0.10.3.jar</div>
<div>所以要先下载</div>
<div>
<pre class="lang:sh decode:true ">[root@monitor src]# wget http://crawler.archive.org/cmdline-jmxclient/cmdline-jmxclient-0.10.3.jar</pre>
<pre class="lang:sh decode:true ">[root@monitor src]# java -jar cmdline-jmxclient-0.10.3.jar - 127.0.0.1:9010 java.lang:type=Memory NonHeapMemoryUsage
Exception in thread "main" java.io.IOException: Failed to retrieve RMIServer stub: javax.naming.ServiceUnavailableException [Root exception is java.rmi.ConnectException: Connection refused to host: 127.0.0.1; nested exception is:
    java.net.ConnectException: 拒绝连接]
    at javax.management.remote.rmi.RMIConnector.connect(RMIConnector.java:369)
    at javax.management.remote.JMXConnectorFactory.connect(JMXConnectorFactory.java:270)
    at org.archive.jmx.Client.execute(Client.java:225)</pre>
果然无法连接，最后查看端口没有监听。所以重启logstash服务，并实时查看错误日志。
<pre class="lang:sh decode:true ">[root@monitor ~]# tailf /var/log/logstash/logstash.err
Errno::EACCES: Permission denied - /app/logstash-log/local6-5160-2015.11.16.log
     initialize at org/jruby/RubyFile.java:363
            new at org/jruby/RubyIO.java:853
           open at /opt/logstash/vendor/bundle/</pre>
后来检查出来是自定义的配置文件有问题，移动配置文件，然后重启就可以了。
<pre class="lang:sh decode:true ">[root@monitor src]# java -jar cmdline-jmxclient-0.10.3.jar - 127.0.0.1:9010 java.lang:type=Memory NonHeapMemoryUsage
11/16/2015 17:02:27 +0800 org.archive.jmx.Client NonHeapMemoryUsage:
committed: 62205952
init: 2555904
max: -1
used: 58527992</pre>
</div>
</div>
