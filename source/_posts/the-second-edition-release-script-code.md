---
title: 脚本发布代码第二版
tags:
  - ansible
  - svn
  - svn update
id: 558
categories:
  - Scripts
  - Svn
date: 2015-09-17 18:16:48
---

之前写的脚本发布代码，每次发布都会checkout所有的代码，数据太多。

今天这个脚本会比上次那个要好很多，只上传指定范围内的版本号。

脚本有很多注释，相信大家都能看懂。我大略写下流程。
<!-- more -->
流程：
1.先获取最新代码版本号。
2.输入指定版本号。
3.列出指定版本号之间的代码文件，并写入到文件中。
4.发布之前备份远程服务器代码。
5.最后上传代码。

下面我贴下脚本和执行后的结果，如果各位有啥问题，可以留言给我。
<pre class="lang:sh decode:true  ">#!/bin/bash
#Author: Charlie.cen
#Email: cenhuqing@gmail.com
#Date: 2015/09/17
# Check if user is root
[ $(id -u) != "0" ] &amp;&amp; echo "Error: You must be root to run this script" &amp;&amp; exit 1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
dat=`date +%Y%m%d-%H%M`
release_path="/home/deploy/version"
svn_workdir="/app/server"
Server_pre="10.19.21.241"
Server_online="10.19.21.242 10.19.21.243"
cd $svn_workdir &amp;&amp; last_version=$(svn update | grep -E "版本|version|Version|At revision" | sed 's/[^0-9]//g')
echo -e "\t\033[32m当前最新的版本号是:\033[0m \033[31m$last_version\033[0m, \033[32m请输入的数字不要超过此版本号!!!\033[0m"
#指定起始和结束版本号
while :
do
	read -p "请输入起始版本号:" start_version
        #read -p "请输入结束版本号:" end_version
	while :
	do
        	if (( $start_version &gt;= $last_version ));then
			echo -e  "\t\033[31m你输入的起始版本号超过限制，请重新输入\033[0m"
			read -p "请输入起始版本号:" start_version
			continue
		else
			read -p "请输入结束版本号:" end_version
			while :
			do
				if (( $end_version &gt;= $last_version ));then
					echo -e "\t\033[31m你输入的结束版本号超过限制，请重新输入\033[0m"
					read -p "请输入结束版本号:" end_version
					continue
				else
					while :
					do
						if (( $start_version &gt;= $end_version ));then
							echo -e "\t\033[31m你输入的起始版本号大于或等于结束版本号，请重新输入\033[0m"
							read -p "请输入起始版本号:" start_version
        						read -p "请输入结束版本号:" end_version
							continue
						else
							if [[ $start_version =~ ^[0-9]+$ ]] &amp;&amp; [[ $end_version =~ ^[0-9]+$ ]];then
                                        			echo -e "\t\033[32m你的起始版本号为:$start_version,你的结束版本号为:$end_version\033[0m"
                                        			break
                               			 	else
                                       		 		echo -e "\t\033[31m你输入的类型错误，请重新输入。例如：123 23 890\033[0m"
                                			fi
						fi
						break
					done
				fi
				break
			done
		fi
		break
	done
	break
done
#进入工作目录，指定版本范围的文件列表写入到文件中
cd $svn_workdir &amp;&amp;  svn log -r $start_version:$end_version -v |egrep '^   M|^   A'|sort |uniq -c |sort -nr|awk '{print $3}' &gt; $release_path/$start_version\_$end_version.txt
if [ $? -eq 0 ];then
	echo -e "\t\033[32m导出指定版本成功\033[0m"
else
	echo -e "\t\033[31m导出指定版本失败\033[0m"
	exit 1
fi
#删除以txt为后缀的文件
sed -i '/.txt/d' $release_path/$start_version\_$end_version.txt
#上传到服务器
while :
do
	echo "请选择要发布的到哪台服务器:"
        echo -e "\t\033[32m1\033[0m. 预发布"
        echo -e "\t\033[32m2\033[0m. 线上"
        read -p "请输入发布到服务器的编号:" Remote_server
        if [ $Remote_server != 1 -a $Remote_server != 2 ];then
                echo -e "\033[31m 输入错误,只能输入数字: 1,2 \033[0m"
	else
		if [ $Remote_server = 1 ];then
			echo -e "\t\033[32m正在备份$Server_pre数据。。。\033[0m"
			ssh root@$Server_pre "cp -r $svn_workdir /app/bak/server-$dat" &amp;&amp; echo -e "\t\033[32m数据备份完成\033[0m" || exit 1
			echo
			echo -e "\t\033[32m正在同步数据到$Server_pre。。。\033[0m"
			while read line;do
				scp -r $svn_workdir$line root@$Server_pre:$svn_workdir$line &gt; /dev/null || exit 2
			done &lt; $release_path/$start_version\_$end_version.txt
			echo -e "\t\033[32m数据同步完成\033[0m"
			break
		else 
			for i in ${Server_online[@]};do
				echo -e "\t\033[32m正在备份$i数据。。。\033[0m"
				ssh root@$i "cp -r $svn_workdir /app/bak/server-$dat" &amp;&amp; echo -e "\t\033[32m数据备份完成\033[0m" || exit 3
				echo
				echo -e "\t\033[32m正在同步数据到$i。。。\033[0m"
				while read line;do
					scp -r $svn_workdir$line root@$i:$svn_workdir$line &gt; /dev/null || exit 4
				done &lt; $release_path/$start_version\_$end_version.txt
				echo -e "\t\033[32m数据同步完成\033[0m"
				echo
			done
			break
		fi
	fi
done</pre>
下面是执行后显示信息，都是中文，俺E文太烂，写出来大家估计也看不懂。
<pre class="lang:sh decode:true">	当前最新的版本号是: 2442, 请输入的数字不要超过此版本号!!!
请输入起始版本号:24300
	你输入的起始版本号超过限制，请重新输入
请输入起始版本号:2430
请输入结束版本号:2410
	你输入的起始版本号大于或等于结束版本号，请重新输入
请输入起始版本号:2440
请输入结束版本号:2441
	你的起始版本号为:2440,你的结束版本号为:2441
	导出指定版本成功
请选择要发布的到哪台服务器:
	1\. 预发布
	2\. 线上
请输入发布到服务器的编号:2
	正在备份10.19.21.242数据。。。
	数据备份完成

	正在同步数据到10.19.21.242。。。
	数据同步完成

	正在备份10.19.21.243数据。。。
	数据备份完成

	正在同步数据到10.19.21.243。。。
	数据同步完成</pre>
可以查看远程服务器里是否备份过文件
<pre class="lang:sh decode:true ">[root@VM-249 scripts]# ansible online -m sh -a "ls -l /app/bak/"
10.19.21.243 | success | rc=0 &gt;&gt;
total 4
drwxr-xr-x 9 root root 4096 Sep 17 17:44 server-20150917-1745

10.19.21.242 | success | rc=0 &gt;&gt;
total 4
drwxr-xr-x 9 root root 4096 Sep 17 17:44 server-20150917-1745</pre>
检查是否发布最新版本到远程服务器，可以打开刚列出的指定版本号文件(2440_2441.txt)
<pre class="lang:sh decode:true">[root@VM-249 scripts]# cat /home/deploy/version/2440_2441.txt 
/admin/apps/api/controllers/CommunityController.php
/admin/apps/admin/controllers/SchoolController.php
/admin/apps/api/controllers/CommunityController.php
</pre>
检查其中一个文件
<pre class="lang:sh decode:true ">[root@VM-249 scripts]# md5sum /app/server/admin/apps/api/controllers/CommunityController.php
a420fa01054605aba3122cda01d8da1f  /app/server/admin/apps/api/controllers/CommunityController.php
[root@VM-249 scripts]# ansible online -m sh -a "md5sum /app/server/admin/apps/api/controllers/CommunityController.php"
10.19.21.243 | success | rc=0 &gt;&gt;
a420fa01054605aba3122cda01d8da1f  /app/server/admin/apps/api/controllers/CommunityController.php

10.19.21.242 | success | rc=0 &gt;&gt;
a420fa01054605aba3122cda01d8da1f  /app/server/admin/apps/api/controllers/CommunityController.php</pre>
&nbsp;
