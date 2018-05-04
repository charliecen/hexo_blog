---
title: 脚本回滚代码
tags:
  - ansible
  - ssh
id: 33
categories:
  - Scripts
date: 2015-09-06 11:46:30
---

上一篇写了发布代码脚本，下面是一篇回滚代码脚本，虽然不是很完善，至少可以方便使用。

有发布就有回滚，防止代码问题能够快速回滚。
<!-- more -->
下面贴代码：
<pre class="lang:sh decode:true">#!/bin/bash
#Author: Charlie.cen
#Email: cenhuqing@gmail.com
#Date: 2015/08/27
# Check if user is root
[ $(id -u) != "0" ] &amp;&amp; echo "Error: You must be root to run this script" &amp;&amp; exit 1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
# Define Var
Server_pre="10.19.21.241"
Server_online="10.19.21.242 10.19.21.243"
release_path="/data/deploy"
Web_dir="/app/server"
while :
do
echo "请选择回滚服务器:"
echo -e "t�33[32m1�33[0m. 预发布"
echo -e "t�33[32m2�33[0m. 线上"
read -p "请输入你服务器的编号: " Remote_server
if [ $Remote_server != 1 -a $Remote_server != 2 ];then
echo -e "�33[31m 输入错误,只能输入数字: 1 , 2�33[0m"
else
if [ $Remote_server == 1 ];then
echo  "请选择回滚时间:"
ssh root@$Server_pre "ls -l $release_path" |awk '{print $9}'
read -p "请输入回滚时间目录: " Time_dir
echo -e "t�33[32m 预发布241,你将回滚到$Time_dir......�33[0m"
ssh root@10.19.21.241 "rm -rf $Web_dir;ln -s $release_path/$Time_dir/server $Web_dir" &amp;&amp; echo  -e "t�33[32m 预发布241,你已经回滚到$Time_dir�33[0m" || echo -e "t�33[31m 预发布241,回滚失败,请查看原因�33[0m"
break
else
echo -e "请选择回滚时间:"
for i in ${Server_online[@]};do
if [ $i == "10.19.21.242" ];then
ssh root@$i "ls -l $release_path" |awk '{print $9}'
read -p "请输入线上242回滚时间目录: " Time_dir_242
echo -e "t�33[32m 线上242,你将回滚到$Time_dir_242......�33[0m"
ssh root@$i "rm -rf $Web_dir;ln -s $release_path/$Time_dir_242/server $Web_dir" &amp;&amp; echo -e "t�33[32m 线上242,你已经回滚到$Time_dir_242�33[0m" || echo -e "t�33[31m 线上242回滚失败,请查看原因�33[0m"
echo
else
ssh root@$i "ls -l $release_path" |awk '{print $9}'
read -p "请输入线上243回滚时间目录: " Time_dir_243
echo -e "t�33[32m 线上243,你将回滚到$Time_dir_243......�33[0m"
ssh root@$i "rm -rf $Web_dir;ln -s $release_path/$Time_dir_243/server $Web_dir" &amp;&amp; echo -e "t�33[32m 线上243,你已经回滚到$Time_dir_242�33[0m" || echo -e "t�33[31m 线上243回滚失败,请查看原因�33[0m"
echo
fi
done
break
fi
fi
done
</pre>
首先看原来的软链接
<pre class="lang:sh decode:true ">[root@VM-249 scripts]# ansible online -m sh -a "ls -l /app/"
10.19.21.243 | success | rc=0 &gt;&gt;
total 0
lrwxrwxrwx 1 root root 35 Aug 27 15:06 server -&gt; /data/deploy/20150826_181338/server

10.19.21.242 | success | rc=0 &gt;&gt;
total 0
lrwxrwxrwx 1 root root 35 Aug 27 15:06 server -&gt; /data/deploy/20150826_181341/server</pre>
执行操作
<pre class="lang:sh decode:true ">[root@VM-249 scripts]# ./roll_back.sh
请选择回滚服务器:
1\. 预发布
2\. 线上
请输入你服务器的编号: 2
请选择回滚时间:

20150825_183223
20150826_163608
20150826_164120
20150826_164640
20150826_171159
20150826_173401
20150826_175930
20150826_181146
20150826_181341
请输入线上242回滚时间目录: 20150826_181146
线上242,你将回滚到20150826_181146......
线上242,你已经回滚到20150826_181146

20150825_183221
20150826_163605
20150826_164118
20150826_164638
20150826_171156
20150826_173359
20150826_175928
20150826_181143
20150826_181338
请输入线上243回滚时间目录: 20150826_181143
线上243,你将回滚到20150826_181143......
线上243,你已经回滚到20150826_181146</pre>
再次查看软链接
<pre class="lang:sh decode:true ">[root@VM-249 scripts]# ansible online -m sh -a "ls -l /app/"
10.19.21.243 | success | rc=0 &gt;&gt;
total 0
lrwxrwxrwx 1 root root 35 Aug 27 15:29 server -&gt; /data/deploy/20150826_181143/server

10.19.21.242 | success | rc=0 &gt;&gt;
total 0
lrwxrwxrwx 1 root root 35 Aug 27 15:29 server -&gt; /data/deploy/20150826_181146/server</pre>
&nbsp;
