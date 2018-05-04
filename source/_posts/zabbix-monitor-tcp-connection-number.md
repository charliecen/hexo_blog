---
title: zabbix监控tcp连接数
tags:
  - netstat
  - tcp_connections
  - zabbix
  - zabbix_get
id: 37
categories:
  - Scripts
  - Zabbix
date: 2015-09-06 17:32:35
---

<div>系统：centos6.5</div>
<div>zabbix：2.4.4</div>
<div>首先创建脚本</div>
<!-- more -->
<div>
<pre class="lang:sh decode:true ">[root@monitor scripts]# vim /usr/local/scripts/tcp_connections.sh
#!/bin/bash
stat() {
        netstat -an | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
        }
case $1 in
        TIME_WAIT)
        stat |grep 'TIME_WAIT' |awk '{print $2}'
        ;;
        CLOSE_WAIT)
        stat | grep 'CLOSE_WAIT' |awk '{print $2}'
        ;;
        FIN_WAIT1)
        stat | grep 'FIN_WAIT1' |awk '{print $2}'
        ;;
        ESTABLISHED)
        stat | grep 'ESTABLISHED' |awk '{print $2}'
        ;;
        SYN_RECV)
        stat |grep 'SYN_RECV' |awk '{print $2}'
        ;;
        LAST_ACK)
        stat |grep 'LAST_ACK' |awk '{print $2}'
        ;;
        LISTEN)
        stat |grep 'LISTEN' |awk '{print $2}'
        ;;
        *)
        echo "Usage: TIME_WAIT CLOSE_WAIT FIN_WAIT1 ESTABLISHED SYN_RECV LAST_ACK LISTEN"
        ;;
esac</pre>
测试脚本是否可用
<pre class="lang:sh decode:true ">[root@monitor scripts]# chmod +x tcp_connections.sh
[root@monitor scripts]# ./tcp_connections.sh ESTABLISHED
125</pre>
编辑zabbix_agentd配置
<pre class="lang:sh decode:true">[root@monitor scripts]# vim /usr/local/etc/zabbix_agentd.conf.d/monitor_tcp_connections.conf
UserParameter=tcp.time_wait,/usr/local/scripts/tcp_connections.sh TIME_WAIT
UserParameter=tcp.close_wait,/usr/local/scripts/tcp_connections.sh CLOSE_WAIT
UserParameter=tcp.fin_wait1,/usr/local/scripts/tcp_connections.sh FIN_WAIT1
UserParameter=tcp.established,/usr/local/scripts/tcp_connections.sh ESTABLISHED
UserParameter=tcp.syn_recv,/usr/local/scripts/tcp_connections.sh SYN_RECV
UserParameter=tcp.last_ack,/usr/local/scripts/tcp_connections.sh LAST_ACK
UserParameter=tcp.listen,/usr/local/scripts/tcp_connections.sh LISTEN</pre>
重启服务
<pre class="lang:sh decode:true">[root@monitor scripts]# /etc/init.d/zabbix_agentd restart
Shutting down zabbix_agentd:                               [确定]
Starting zabbix_agentd:                                    [确定]</pre>
测试监控是否有数据
<pre class="lang:sh decode:true ">[root@monitor scripts]# zabbix_get -s localhost -k tcp.established
126</pre>
然后在web里创建模版，方便以后多台添加

![](http://blog.cenhq.com/wp-content/uploads/2015/09/1.png)

</div>
填写模版名称

![](http://blog.cenhq.com/wp-content/uploads/2015/09/2.png)

&nbsp;

创建监控项

![](http://blog.cenhq.com/wp-content/uploads/2015/09/3.png)![](http://blog.cenhq.com/wp-content/uploads/2015/09/4.png)![](http://blog.cenhq.com/wp-content/uploads/2015/09/5.png)

&nbsp;

创建图形

![](http://blog.cenhq.com/wp-content/uploads/2015/09/6.png)![](http://blog.cenhq.com/wp-content/uploads/2015/09/7.png)

&nbsp;
<div>模版创建完成后，要关联到监控主机</div>
<div>点击主机，选择模版</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/09/9.png)</div>
<div></div>
等一会儿数据图形就会出现

![](http://blog.cenhq.com/wp-content/uploads/2015/09/8.png)

&nbsp;
