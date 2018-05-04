---
title: 脚本自动添加ip到iptables
tags:
  - awk
  - iptables
id: 722
categories:
  - Iptables
  - Scripts
date: 2015-12-17 18:15:33
---

nginx日志里有一些来历不明的ip攻击或者是用ssh来尝试登录你的密码

日志会记录这些来源的ip地址，根据ip地址来加入到iptables INPUT里，默认INPUT链为DROP

下面是我写的一个脚本，可以放到计划任务里，每天来统计
<!--more-->
<pre class="lang:sh decode:true ">[root@VM-241 ~]# vim add_iptables.sh 

#!/bin/bash

#日志文件
logfile=/data/app/nginx/logs/access.log

#统计ip，可以根据时间统计
awk '/passport-send_vcode_sms.html/{print $1}' $logfile |sort |uniq -c |sort -nr &gt; /root/ip.txt

#已经在iptables中的地址
droped_ip=$(iptables -L -n |awk '/^DROP/{print $4}')

#未加入iptables中的地址
drop_ip=$(awk '{print $2}' /root/ip.txt)

#比较两个数组不同，把不同的ip加入到防火墙中
add_ip=$(awk 'NR==1{for(i=1;i&lt;=NF;i++) B[$i]=1}NR==2{for(j=1;j&lt;=NF;j++) {if(B[$j]!=1) print $j}} ' &lt;(echo $droped_ip) &lt;(echo $drop_ip))
for i in $add_ip
do
        iptables -A INPUT -s $i -j DROP &amp;&amp; echo "已添加IP: $i 到防火墙丢弃策略中。" 
done

#保存新加入的策略
/etc/init.d/iptables save
/etc/init.d/iptables reload</pre>
执行前的iptables策略
<pre class="lang:sh decode:true ">[root@VM-241 ~]# iptables -L -n
Chain INPUT (policy DROP)
target     prot opt source               destination         
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:21 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:8080 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:3690 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:80 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:443 
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           limit: avg 100/sec burst 100 
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           limit: avg 1/sec burst 10 
syn-flood  tcp  --  0.0.0.0/0            0.0.0.0/0           tcp flags:0x17/0x02 
REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited 
DROP       all  --  114.116.14.47        0.0.0.0/0           
DROP       all  --  1.58.120.217         0.0.0.0/0</pre>
执行脚本
<pre class="lang:sh decode:true ">[root@VM-241 ~]# bash add_iptables.sh 
已添加IP: 218.88.85.184 到防火墙丢弃策略中。
已添加IP: 122.227.51.102 到防火墙丢弃策略中。
已添加IP: 122.235.180.60 到防火墙丢弃策略中。
已添加IP: 122.95.241.64 到防火墙丢弃策略中。
已添加IP: 210.21.220.68 到防火墙丢弃策略中。
已添加IP: 106.226.24.23 到防火墙丢弃策略中。
已添加IP: 60.184.47.12 到防火墙丢弃策略中。
已添加IP: 220.113.94.30 到防火墙丢弃策略中。
已添加IP: 58.253.150.96 到防火墙丢弃策略中。
已添加IP: 110.81.117.78 到防火墙丢弃策略中。
已添加IP: 119.132.156.176 到防火墙丢弃策略中。
已添加IP: 220.171.210.251 到防火墙丢弃策略中。
已添加IP: 101.233.125.137 到防火墙丢弃策略中。
已添加IP: 60.162.152.102 到防火墙丢弃策略中。
已添加IP: 123.97.164.49 到防火墙丢弃策略中。
已添加IP: 114.83.216.53 到防火墙丢弃策略中。
已添加IP: 171.117.124.119 到防火墙丢弃策略中。
已添加IP: 58.254.4.13 到防火墙丢弃策略中。</pre>
执行脚本后的iptables策略
<pre class="lang:sh decode:true ">[root@VM-241 ~]# iptables -L -n
Chain INPUT (policy DROP)
target     prot opt source               destination         
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:22 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:21 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:8080 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:3690 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:80 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           state NEW tcp dpt:443 
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           limit: avg 100/sec burst 100 
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           limit: avg 1/sec burst 10 
syn-flood  tcp  --  0.0.0.0/0            0.0.0.0/0           tcp flags:0x17/0x02 
REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited 
DROP       all  --  114.116.14.47        0.0.0.0/0           
DROP       all  --  1.58.120.217         0.0.0.0/0           
DROP       all  --  218.88.85.184        0.0.0.0/0           
DROP       all  --  122.227.51.102       0.0.0.0/0           
DROP       all  --  122.235.180.60       0.0.0.0/0           
DROP       all  --  122.95.241.64        0.0.0.0/0           
DROP       all  --  210.21.220.68        0.0.0.0/0           
DROP       all  --  106.226.24.23        0.0.0.0/0           
DROP       all  --  60.184.47.12         0.0.0.0/0           
DROP       all  --  220.113.94.30        0.0.0.0/0           
DROP       all  --  58.253.150.96        0.0.0.0/0           
DROP       all  --  110.81.117.78        0.0.0.0/0           
DROP       all  --  119.132.156.176      0.0.0.0/0           
DROP       all  --  220.171.210.251      0.0.0.0/0           
DROP       all  --  101.233.125.137      0.0.0.0/0           
DROP       all  --  60.162.152.102       0.0.0.0/0           
DROP       all  --  123.97.164.49        0.0.0.0/0           
DROP       all  --  114.83.216.53        0.0.0.0/0           
DROP       all  --  171.117.124.119      0.0.0.0/0           
DROP       all  --  58.254.4.13          0.0.0.0/0</pre>
&nbsp;
