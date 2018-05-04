---
title: 脚本发布代码
tags:
  - ansible
  - ssh
  - svn
id: 4
categories:
  - Scripts
date: 2015-09-06 11:33:48
---

<div>

环境：centos6.5

代码服务器：10.19.21.249

预发布服务器：10.19.21.241

线上服务器：10.19.21.242 10.19.21.243
<!-- more -->
&nbsp;

发布流程：

1\. 在代码服务器上导出你要发布的项目

2\. 然后选择你将要发布到哪台服务器（预发布｜线上）

3\. 使用rsync同步到你选择的服务器

4\. 根据你同步的目录创建软链接到网站家目录

</div>
<div></div>
<div>
<div>大概就4个步骤，下面我贴上脚本，有问题可以给我留言。写的不好请多指教。</div>
<div>
<pre class="lang:sh decode:true ">#!/bin/bash
#Author: Charlie.cen
#Email: cenhuqing@gmail.com
#Date: 2015/08/25

# Check if user is root
[ $(id -u) != "0" ] &amp;&amp; echo "Error: You must be root to run this script" &amp;&amp; exit 1

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear

svn_user="charlie"
svn_pass="charlie_pwd"
checkout_path="/home/deploy/checkout"
release_path="/app/deploy"
svn_url="svn://localhost/server"
log="/var/log/apr_v1.log"
time_dir=`date +%Y%m%d_%H%M%S`

#Define checkout directory
if [ ! -d $checkout_path/$time_dir ];then
	mkdir -p $checkout_path/$time_dir
fi

#Chiose your svn project
while :
do
	echo
	echo "请选择你要打包的项目:"
	#echo "Please select your zip project:"
	echo -e "\t\033[32m1\033[0m.  admin"
	echo -e "\t\033[32m2\033[0m.  baiaimama"
	echo -e "\t\033[32m3\033[0m.  bi"
	echo -e "\t\033[32m4\033[0m.  html5"
	echo -e "\t\033[32m5\033[0m.  integration"
	echo -e "\t\033[32m6\033[0m.  school"
	echo -e "\t\033[32m7\033[0m.  site"
	echo -e "\t\033[32m8\033[0m.  server(全部)"
	#read -p "Please enter a number:" Num
	read -p "请输入你要打包的编号:" Num
	if [ $Num != 1 -a $Num != 2 -a $Num != 3 -a $Num != 4 -a $Num != 5 -a $Num != 6 -a $Num != 7 -a $Num != 8 ];then
		echo -e "\033[31m 输入错误,只能输入数字: 1,2,3,4,5,6,7,8\033[0m"
		#echo -e "\033[31minput error! Please only input number 1,2,3,4,5,6,7,8\033[0m"
	else
		if [ $Num == 1 ];then
			project=admin
			echo
			echo -e "\t\033[32m 正在打包 $project ...... \033[0m"
			echo
			svn export --non-interactive --trust-server-cert  --username $svn_user --password $svn_pass $svn_url/$project $checkout_path/$time_dir/$project &gt; /dev/null &amp;&amp; echo -e "\t\033[32m $project 打包成功 \033[0m" || echo "\t\033[31m $project 打包失败 \033[0m"
			echo
			break
		elif [ $Num == 2 ];then
			project=baiaimama
			echo
			echo -e "\t\033[32m 正在打包 $project ...... \033[0m"
			echo
			svn export --non-interactive --trust-server-cert  --username $svn_user --password $svn_pass $svn_url/$project $checkout_path/$time_dir/$project  &gt; /dev/null &amp;&amp; echo -e "\t\033[32m $project 打包成功 \033[0m" || echo "\t\033[31m $project 打包失败 \033[0m"
                        echo
			break
		elif [ $Num == 3 ];then
			project=bi
			echo
                        echo -e "\t\033[32m 正在打包 $project ...... \033[0m"
                        echo
			svn export --non-interactive --trust-server-cert  --username $svn_user --password $svn_pass $svn_url/$project $checkout_path/$time_dir/$project  &gt; /dev/null &amp;&amp; echo -e "\t\033[32m $project 打包成功 \033[0m" || echo "\t\033[31m $project 打包失败 \033[0m"
                        echo
			break
		elif [ $Num == 4 ];then
			project=html5
			echo
                        echo -e "\t\033[32m 正在打包 $project ...... \033[0m"
                        echo
                        svn export --non-interactive --trust-server-cert  --username $svn_user --password $svn_pass $svn_url/$project $checkout_path/$time_dir/$project &gt; /dev/null &amp;&amp; echo -e "\t\033[32m $project 打包成功 \033[0m" || echo "\t\033[31m $project 打包失败 \033[0m"
                        echo
			break
		elif [ $Num == 5 ];then
			project=integration
			echo
                        echo -e "\t\033[32m 正在打包 $project ...... \033[0m"
                        echo
                        svn export --non-interactive --trust-server-cert  --username $svn_user --password $svn_pass $svn_url/$project $checkout_path/$time_dir/$project &gt; /dev/null &amp;&amp; echo -e "\t\033[32m $project 打包成功 \033[0m" || echo "\t\033[31m $project 打包失败 \033[0m"
                        echo
			break
		elif [ $Num == 6 ];then
			project=school
			echo
                        echo -e "\t\033[32m 正在打包 $project ...... \033[0m"
                        echo
                        svn export --non-interactive --trust-server-cert  --username $svn_user --password $svn_pass $svn_url/$project $checkout_path/$time_dir/$project &gt; /dev/null &amp;&amp; echo -e "\t\033[32m $project 打包成功 \033[0m" || echo "\t\033[31m $project 打包失败 \033[0m"
                        echo
			break
		elif [ $Num == 7 ];then
			project=site
			echo
                        echo -e "\t\033[32m 正在打包 $project ...... \033[0m"
                        echo
                        svn export --non-interactive --trust-server-cert  --username $svn_user --password $svn_pass $svn_url/$project $checkout_path/$time_dir/$project &gt; /dev/null &amp;&amp; echo -e "\t\033[32m $project 打包成功 \033[0m" || echo "\t\033[31m $project 打包失败 \033[0m"
                        echo
			break
		elif [ $Num == 8 ];then
			project=server
			echo
                        echo -e "\t\033[32m 正在打包 $project ...... \033[0m"
                        echo
                        svn export --non-interactive --trust-server-cert  --username $svn_user --password $svn_pass $svn_url $checkout_path/$time_dir/$project &gt; /dev/null &amp;&amp; echo -e "\t\033[32m $project 打包成功 \033[0m" || echo "\t\033[31m $project 打包失败 \033[0m"
                        echo
			break
		else
			echo -e "\t\033[31m $project 打包失败 \033[0m" 
			break
		fi
	fi	
done

IP_249="10.19.21.249"
#Server_pre="10.19.21.241"
Server_pre="115.29.199.174"
Server_online="10.19.21.242 10.19.21.243"
Web_dir="/app/server"

#Choise Remote Server
while :
do	
	#echo "Please select rsync to server"
	echo "请选择要发布的到哪台服务器:"
	echo -e "\t\033[32m1\033[0m. 预发布"
        echo -e "\t\033[32m2\033[0m. 线上"
	#read -p "Please enter a number:" Remote_server
	read -p "请输入发布到服务器的编号:" Remote_server
	if [ $Remote_server != 1 -a $Remote_server != 2 ];then
		echo -e "\033[31m 输入错误,只能输入数字: 1,2 \033[0m"
		#echo -e "\033[31minput error! Please only input number 1,2 \033[0m"
	else
		if [ $Remote_server == 1 ];then
			echo
			echo -e "\t\033[32m 正在同步文件到预发布...... \033[0m"
			echo
			ansible pre -m copy -a "src=mk_dir_v1.sh dest=/usr/local/scripts/ mode=755"  &gt;&gt; $log || exit 1
			ansible pre -m sh -a "source /usr/local/scripts/mk_dir_v1.sh" &gt;&gt; $log  || exit 1
			last_dir=$(ssh root@$Server_pre "ls -ltr $release_path |tail -n 1" |awk '{print $9}')
			rsync -rlpgoDut --exclude-from=/opt/exclude.txt $checkout_path/$time_dir/$project root@$Server_pre:$release_path/$last_dir/server &amp;&amp; echo -e  "\t\033[32m 同步到预发布成功\033[0m" || echo -e "\t\033[31m 同步到预发布失败. \033[0m"
			echo
			ssh root@$Server_pre "rm -f $Web_dir;ln -s $release_path/$last_dir/server $Web_dir" &amp;&amp; echo -e "\t\033[32m 预发布发布成功 \033[0m" || echo -e "\t\033[31m 预发布发布失败\033[0m"
			break
		else
			echo
			echo -e "\t\033[32m 正在同步到线上...... \033[0m"
                        echo
			ansible online -m copy -a "src=mk_dir_v1.sh dest=/usr/local/scripts/ mode=755"  &gt;&gt; $log || exit 1
			ansible online -m sh -a "source /usr/local/scripts/mk_dir_v1.sh" &gt;&gt; $log || exit 1
			for i in ${Server_online[@]};do
				if [ $i == "10.19.21.242" ];then
					last_dir_242=$(ssh root@$i "ls -ltr $release_path |tail -n 1" |awk '{print $9}')
					rsync -rlpgoDut --exclude-from=/opt/exclude.txt $checkout_path/$time_dir/$project root@$i:$release_path/$last_dir_242/server &amp;&amp; echo -e "\t\033[32m 同步到线上242成功 \033[0m" || echo -e "\t\033[31m 同步到线上242失败  \033[0m"
					echo
					ssh root@$i "rm -f $Web_dir;ln -s $release_path/$last_dir_242/server $Web_dir" &amp;&amp; echo -e "\t\033[32m 线上242发布成功 \033[0m" || echo -e "\t\033[31m 线上242发布失败  \033[0m"
					echo
				else
					last_dir_243=$(ssh root@$i "ls -ltr /data/deploy |tail -n 1" |awk '{print $9}')
					rsync -rlpgoDut --exclude-from=/opt/exclude.txt $checkout_path/$time_dir/$project root@$i:$release_path/$last_dir_243/server &amp;&amp; echo -e "\t\033[32m 同步到线上243成功 \033[0m" || echo -e "\t\033[31m 同步到线上243失败 \033[0m"
					echo
					ssh root@$i "rm -f $Web_dir;ln -s $release_path/$last_dir_242/server $Web_dir" &amp;&amp;  echo -e "\t\033[32m 线上243发布成功 \033[0m" || echo -e "\t\033[31m 线上243发布失败  \033[0m"
					echo
				fi
				echo
			done
			break
		fi
	fi
done</pre>
脚本中用到了ansible，主机定义如下：
<pre class="lang:sh decode:true ">[pre]
10.19.21.241 ansible_ssh_user=root ansible_ssh_pass=ooxx

[online]
10.19.21.242 ansible_ssh_user=root ansible_ssh_pass=ooxx
10.19.21.243 ansible_ssh_user=root ansible_ssh_pass=ooxx</pre>
还有个问题就是要在被发布端的定义根据时间生成的目录，这个脚本是上面的ansible调用。下面贴脚本
<pre class="lang:sh decode:true ">#!/bin/bash

dir_time=$(date +%Y%m%d_%H%M%S)
release_path="/app/deploy"
log="/var/log/copy.log"

if [ ! -d $release_path/$dir_time ];then
	mkdir -p $release_path/$dir_time
fi

second_last_dir=$(ls -ltc $release_path |egrep '^d'|awk 'NR==2{print $9}')
cp -rf $release_path/$second_last_dir/* $release_path/$dir_time/ &amp;&amp; echo "Copy $release_path/$second_last_dir/server to $release_path/$dir_time/ successful." &gt;&gt; $log || echo "Copy $release_path/$second_last_dir/server to $release_path/$dir_time/ failed." &gt;&gt; $log</pre>
最终执行结果
<pre class="lang:sh decode:true ">请选择你要打包的项目:
1\.  admin
2\.  baiaimama
3\.  bi
4\.  html5
5\.  integration
6\.  school
7\.  site
8\.  server(全部)
请输入你要打包的编号:4

正在打包 html5 ......

html5 打包成功

请选择要发布的到哪台服务器:
1\. 预发布
2\. 线上
请输入发布到服务器的编号:2

正在同步到线上......

同步到线上242成功

线上242发布成功

同步到线上243成功

线上243发布成功</pre>
查看代码是否发布
<pre class="lang:sh decode:true ">#  ansible online -m sh -a 'ls -l /app/server'
10.19.21.243 | success | rc=0 &gt;&gt;
lrwxrwxrwx 1 root root 35 Aug 26 18:14 /app/server -&gt; /data/deploy/20150826_181341/server

10.19.21.242 | success | rc=0 &gt;&gt;
lrwxrwxrwx 1 root root 35 Aug 26 18:14 /app/server -&gt; /data/deploy/20150826_181341/server</pre>
&nbsp;

</div>
</div>
