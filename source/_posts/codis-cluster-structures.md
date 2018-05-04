---
title: codis集群搭建
tags:
  - codis
  - redis-cli
id: 83
categories:
  - Codis
date: 2015-09-15 17:40:24
---

<div>Codis 是一个分布式 Redis 解决方案, 对于上层的应用来说, 连接到 Codis Proxy 和连接原生的 Redis Server 没有明显的区别 (不支持的命令列表), 上层应用可以像使用单机的 Redis 一样使用, Codis 底层会处理请求的转发, 不停机的数据迁移等工作, 所有后边的一切事情, 对于前面的客户端来说是透明的, 可以简单的认为后边连接的是一个内存无限大的 Redis 服务.</div>
<!-- more -->
<div>Codis 由四部分组成:</div>
*   Codis Proxy (codis-proxy)
*   Codis Manager (codis-config)
*   Codis Redis (codis-server)
*   ZooKeeper
<div>codis-proxy 是客户端连接的 Redis 代理服务, codis-proxy 本身实现了 Redis 协议, 表现得和一个原生的 Redis 没什么区别 (就像 Twemproxy), 对于一个业务来说, 可以部署多个 codis-proxy, codis-proxy 本身是无状态的.</div>
<div></div>
<div>codis-config 是 Codis 的管理工具, 支持包括, 添加/删除 Redis 节点, 添加/删除 Proxy 节点, 发起数据迁移等操作. codis-config 本身还自带了一个 http server, 会启动一个 dashboard, 用户可以直接在浏览器上观察 Codis 集群的运行状态.</div>
<div></div>
<div>codis-server 是 Codis 项目维护的一个 Redis 分支, 基于 2.8.21 开发, 加入了 slot 的支持和原子的数据迁移指令. Codis 上层的 codis-proxy 和 codis-config 只能和这个版本的 Redis 交互才能正常运行.</div>
<div></div>
<div>Codis 依赖 ZooKeeper 来存放数据路由表和 codis-proxy 节点的元信息, codis-config 发起的命令都会通过 ZooKeeper 同步到各个存活的 codis-proxy.</div>
<div></div>
<div>Codis 支持按照 Namespace 区分不同的产品, 拥有不同的 product name 的产品, 各项配置都不会冲突.</div>
<div></div>

### 1.安装go环境

<div>Go语言是[谷歌](http://baike.baidu.com/view/1931.htm)2009发布的第二款开源编程语言。</div>
<div>Go语言专门针对[多处理器系统](http://baike.baidu.com/view/4694429.htm)应用程序的编程进行了优化，使用Go编译的程序可以媲美C或C++代码的速度，而且更加安全、支持并行进程。</div>
<div>
<pre class="lang:sh decode:true">下载地址：https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz
[root@VM-241 ~]# tar xf go1.5.1.linux-amd64.tar.gz -C /usr/local/
[root@VM-241 ~]# vim /etc/profile
export GOROOT=/usr/local/go
export GOPATH=/usr/local/codis
export PATH=$PATH:$GOROOT/bin

[root@VM-241 ~]# source /etc/profile</pre>

### 2.安装zookeeper

ZooKeeper是一个[分布式](http://baike.baidu.com/view/402382.htm)的，开放源码的[分布式应用程序](http://baike.baidu.com/view/553502.htm)协调服务，是[Google](http://baike.baidu.com/view/105.htm)的Chubby一个[开源](http://baike.baidu.com/view/9664.htm)的实现，是Hadoop和Hbase的重要组件。它是一个为分布式应用提供一致性服务的软件，提供的功能包括：配置维护、名字服务、分布式同步、组服务等。

zookeeper依赖java环境，所以还要先安装java
<pre class="lang:sh decode:true">[root@VM-241 ~]# yum install -y java-1.8.0-openjdk</pre>
<pre class="lang:sh decode:true">zookeeper下载地址：
[root@VM-241 ~]# wget http://apache.stu.edu.tw/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz

[root@VM-241 ~]# tar xf zookeeper-3.4.6.tar.gz
[root@VM-241 ~]# mv zookeeper-3.4.6 /usr/local/zookeeper

[root@VM-241 ~]# chown root. /usr/local/zookeeper -R
[root@VM-241 ~]# cp /usr/local/zookepper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg

启动服务
[root@VM-241 ~]# /usr/local/zookeeper/bin/zkServer.sh start

[root@VM-241 ~]# netstat -lutnp |grep java
tcp        0      0 0.0.0.0:2181                0.0.0.0:*                   LISTEN      1126/java
tcp        0      0 0.0.0.0:52774               0.0.0.0:*                   LISTEN      1126/java</pre>

### 3.安装codis

建议只通过go get命令来下载codis，除非你非常熟悉go语言的目录引用形式从而不会导致代码放错地方。该命令会下载master分支的最新版，我们会确保master分支的稳定。
<pre class="lang:sh decode:true">[root@VM-241 ~]# go get -u -d github.com/wandoulabs/codis

[root@VM-241 ~]# cd $GOPATH/src/github.com/wandoulabs/codis

[root@VM-241 codis]# ./bootstrap.sh

Hint: It's a good idea to run 'make test' ;)

make[2]: Leaving directory `/usr/local/codis/src/github.com/wandoulabs/codis/extern/redis-2.8.21/src'
make[1]: Leaving directory `/usr/local/codis/src/github.com/wandoulabs/codis/extern/redis-2.8.21'
go test ./pkg/... ./cmd/... -race
ok      github.com/wandoulabs/codis/pkg/models    20.779s
ok      github.com/wandoulabs/codis/pkg/proxy    10.525s
ok      github.com/wandoulabs/codis/pkg/proxy/redis    10.255s
ok      github.com/wandoulabs/codis/pkg/proxy/router    2.170s
?       github.com/wandoulabs/codis/pkg/utils    [no test files]
?       github.com/wandoulabs/codis/pkg/utils/assert    [no test files]
?       github.com/wandoulabs/codis/pkg/utils/atomic2    [no test files]
ok      github.com/wandoulabs/codis/pkg/utils/bytesize    0.016s
?       github.com/wandoulabs/codis/pkg/utils/errors    [no test files]
?       github.com/wandoulabs/codis/pkg/utils/log    [no test files]
?       github.com/wandoulabs/codis/pkg/utils/trace    [no test files]
?       github.com/wandoulabs/codis/cmd/cconfig    [no test files]
?       github.com/wandoulabs/codis/cmd/proxy    [no test files]</pre>
执行全部指令后，会在 bin 文件夹生成 codis-config, codis-proxy 两个可执行文件, (另外, bin/assets 文件夹是 codis-config 的 dashboard http 服务需要的前端资源, 需要和 codis-config 放置在同一文件夹下)

### 4.部署

<div>配置文件,codis-config 和 codis-proxy 在不加 -c 参数的时候, 默认会读取当前目录下的 config.ini 文件</div>
<div>
<pre class="lang:sh decode:true">[root@VM-241 codis]# egrep -v '^#|^$' config.ini
coordinator=zookeeper
zk=127.0.0.1:2181
product=test
dashboard_addr=10.19.21.241:18087
password=
backend_ping_period=5
session_max_timeout=1800
session_max_bufsize=131072
session_max_pipeline=1024
zk_session_timeout=30
proxy_id=proxy_1</pre>

##### 4.1 启动dashboard

<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-config dashboard</pre>
打开浏览器

![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-5@2x.jpg)

</div>
</div>

##### 4.2 初始化slots

<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-config slot init
{
  "msg": "OK",
  "ret": 0
}
该命令会在zookeeper上创建slot相关信息</pre>

##### 4.3 启动codis redis

<pre class="lang:sh decode:true">[root@VM-241 codis]# bin/codis-server --port 6379 &amp;
[root@VM-241 codis]# bin/codis-server --port 6380 &amp;
[root@VM-241 codis]# bin/codis-server --port 6479 &amp;
[root@VM-241 codis]# bin/codis-server --port 6480 &amp;</pre>

##### 4.4 添加redis server group

<div>每个server group作为一个reds服务器组存在，只允许有一个master，可以有多个slave，group id仅支持大于等于1的整数</div>
<div>例如：添加两个server group，每个group有两个reds实例，group id分别为1和2，reds实例为一主一从。</div>
<div>添加一个group， group的id为1，并添加一个reds master到该group</div>
<div>
<pre class="lang:sh decode:true">[root@VM-241 codis]# bin/codis-config server add 1 localhost:6379 master
{
  "msg": "OK",
  "ret": 0
}
添加一个redis slave到该group
[root@VM-241 codis]# bin/codis-config server add 1 localhost:6380 slave
{
  "msg": "OK",
  "ret": 0
}
类似再添加group，group的id为2
[root@VM-241 codis]# bin/codis-config server add 2 localhost:6479 master
{
  "msg": "OK",
  "ret": 0
}
[root@VM-241 codis]# bin/codis-config server add 2 localhost:6480 slave
{
  "msg": "OK",
  "ret": 0
}</pre>

#### ![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-7@2x.jpg)

### 5. **设置 server group 服务的 slot 范围**

<div>Codis 采用 Pre-sharding 的技术来实现数据的分片, 默认分成 1024 个 slots (0-1023), 对于每个key来说, 通过以下公式确定所属的 Slot Id : SlotId = crc32(key) % 1024 每一个 slot 都会有一个且必须有一个特定的 server group id 来表示这个 slot 的数据由哪个 server group 来提供.</div>
<div>例如：设置编号为[0, 511]的 slot 由 server group 1 提供服务, 编号 [512, 1023] 的 slot 由 server group 2 提供服务</div>
<div>
<pre class="lang:sh decode:true">[root@VM-241 codis]# bin/codis-config slot range-set 0 511 1 online
{
  "msg": "OK",
  "ret": 0
}
[root@VM-241 codis]# bin/codis-config slot range-set 512 1023 2 online
{
  "msg": "OK",
  "ret": 0
}</pre>

###  6\. 启动codis-proxy

<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-proxy -c config.ini -L proxy.log --cpu=2 --addr=0.0.0.0:19000 --http-addr=0.0.0.0:11000 &amp;
[1] 27716
[root@VM-241 codis]#
  _____  ____    ____/ /  (_)  _____
 / ___/ / __ \  / __  /  / /  / ___/
/ /__  / /_/ / / /_/ /  / /  (__  )
\___/  \____/  \__,_/  /_/  /____/</pre>
刚启动的 codis-proxy 默认是处于 offline状态的, 然后设置 proxy 为 online 状态, 只有处于 online 状态的 proxy 才会对外提供服务
<pre class="lang:sh decode:true ">[root@VM-241 codis]#  bin/codis-config -c config.ini proxy online proxy_1
{
  "msg": "OK",
  "ret": 0
}</pre>
![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-3@2x.jpg)

### 7.测试分片

<pre class="lang:sh decode:true ">[root@VM-241 codis]# redis-cli -h 127.0.0.1 -p 19000
redis 127.0.0.1:19000&gt; set a 1
OK
redis 127.0.0.1:19000&gt; set b 2
OK
redis 127.0.0.1:19000&gt; set c 3
OK</pre>
只有在group_2有数据。应该是数据量少

![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-8@2x.jpg)

脚本批量插入数据
<pre class="lang:sh decode:true ">#!/bin/bash

number=2000
let i=0
while  [ $i -le $number ];do
    redis-cli -h 10.19.21.241 -p 19000 set name{$i} ${i}
    ((i++))
done</pre>
![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-9@2x.jpg)

![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-10@2x.jpg)

### 8.在线添加slave

首先再启动两个server
<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-server --port 6381 &amp;
[root@VM-241 codis]# bin/codis-server --port 6481 &amp;</pre>
然后将两个server分别添加到group中

&nbsp;

#### ![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-11@2x.jpg)

![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-12@2x.jpg)

![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-13@2x.jpg)

### 9\. 移除节点

##### 9.1 设置proxy为offline

<pre class="lang:sh decode:true">[root@VM-241 codis]# bin/codis-config proxy offline proxy_1
{
  "msg": "OK",
  "ret": 0
}
[5]   Exit 1                  bin/codis-proxy -c config.ini -L proxy.log --cpu=2 --addr=0.0.0.0:19000 --http-addr=0.0.0.0:11000</pre>

##### 9.2 重新初始化slot

<pre class="lang:sh decode:true">[root@VM-241 codis]# bin/codis-config slot init -f
{
  "msg": "OK",
  "ret": 0
}</pre>

##### 9.3 移除节点

<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-config server remove-group 1
{
  "msg": "OK",
  "ret": 0
}
[root@VM-241 codis]# bin/codis-config server remove-group 2
{
  "msg": "OK",
  "ret": 0
}
[root@VM-241 codis]# bin/codis-config server remove-group 3
{
  "msg": "OK",
  "ret": 0
}</pre>
查看页面

![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150915-14@2x.jpg)

###### ##############################################

错误1：

启动dashboard报错，提示已经存在pid文件
<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-config -c config.ini dashboard &amp;
[1] 441
[root@VM-241 codis]# 2015/09/15 10:23:05 dashboard.go:160: [INFO] dashboard listening on addr: :18087
2015/09/15 10:23:05 dashboard.go:234: [PANIC] create zk node failed
[error]: dashboard already exists: {"addr": "10.19.21.241:18087", "pid": 12687}
[stack]: 
    3   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/dashboard.go:234
            main.runDashboard
    2   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/dashboard.go:54
            main.cmdDashboard
    1   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/main.go:84
            main.runCommand
    0   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/main.go:151
            main.main
        ... ...

[1]+  Exit 1                  bin/codis-config -c config.ini dashboard</pre>
解决办法：

到zk里删除dashboard
<pre class="lang:sh decode:true ">[root@VM-241 codis]# /usr/local/zookeeper/bin/zkCli.sh 
Connecting to localhost:2181
2015-09-15 10:25:16,154 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.6-1569965, built on 02/20/2014 09:09 GMT
2015-09-15 10:25:16,162 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=VM-241
2015-09-15 10:25:16,162 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=1.8.0_51
2015-09-15 10:25:16,167 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2015-09-15 10:25:16,168 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.51-1.b16.el6_7.x86_64/jre
2015-09-15 10:25:16,168 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/usr/local/zookeeper/bin/../build/classes:/usr/local/zookeeper/bin/../build/lib/*.jar:/usr/local/zookeeper/bin/../lib/slf4j-log4j12-1.6.1.jar:/usr/local/zookeeper/bin/../lib/slf4j-api-1.6.1.jar:/usr/local/zookeeper/bin/../lib/netty-3.7.0.Final.jar:/usr/local/zookeeper/bin/../lib/log4j-1.2.16.jar:/usr/local/zookeeper/bin/../lib/jline-0.9.94.jar:/usr/local/zookeeper/bin/../zookeeper-3.4.6.jar:/usr/local/zookeeper/bin/../src/java/lib/*.jar:/usr/local/zookeeper/bin/../conf:
2015-09-15 10:25:16,168 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
2015-09-15 10:25:16,168 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2015-09-15 10:25:16,169 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=&lt;NA&gt;
2015-09-15 10:25:16,169 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2015-09-15 10:25:16,169 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2015-09-15 10:25:16,169 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=2.6.32-573.1.1.el6.x86_64
2015-09-15 10:25:16,170 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2015-09-15 10:25:16,170 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2015-09-15 10:25:16,170 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/usr/local/codis/src/github.com/wandoulabs/codis
2015-09-15 10:25:16,173 [myid:] - INFO  [main:ZooKeeper@438] - Initiating client connection, connectString=localhost:2181 sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@7aec35a
Welcome to ZooKeeper!
2015-09-15 10:25:16,296 [myid:] - INFO  [main-SendThread(VM-241:2181):ClientCnxn$SendThread@975] - Opening socket connection to server VM-241/127.0.0.1:2181\. Will not attempt to authenticate using SASL (unknown error)
JLine support is enabled
2015-09-15 10:25:16,542 [myid:] - INFO  [main-SendThread(VM-241:2181):ClientCnxn$SendThread@852] - Socket connection established to VM-241/127.0.0.1:2181, initiating session
2015-09-15 10:25:16,583 [myid:] - INFO  [main-SendThread(VM-241:2181):ClientCnxn$SendThread@1235] - Session establishment complete on server VM-241/127.0.0.1:2181, sessionid = 0x14fcb1992f9000a, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: localhost:2181(CONNECTED) 0] help
ZooKeeper -server host:port cmd args
	stat path [watch]
	set path data [version]
	ls path [watch]
	delquota [-n|-b] path
	ls2 path [watch]
	setAcl path acl
	setquota -n|-b val path
	history 
	redo cmdno
	printwatches on|off
	delete path [version]
	sync path
	listquota path
	rmr path
	get path [watch]
	create [-s] [-e] path data acl
	addauth scheme auth
	quit 
	getAcl path
	close 
	connect host:port

[zk: localhost:2181(CONNECTED) 6] delete /zk/codis/db_test/dashboard
[zk: localhost:2181(CONNECTED) 7] quit
Quitting...
2015-09-15 10:26:07,248 [myid:] - INFO  [main-EventThread:ClientCnxn$EventThread@512] - EventThread shut down
2015-09-15 10:26:07,249 [myid:] - INFO  [main:ZooKeeper@684] - Session: 0x14fcb1992f9000a closed</pre>
<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-config -c config.ini dashboard &amp;
[1] 623
[root@VM-241 codis]# 2015/09/15 10:26:11 dashboard.go:160: [INFO] dashboard listening on addr: :18087
2015/09/15 10:26:11 dashboard.go:143: [INFO] dashboard node created: /zk/codis/db_test/dashboard, {"addr": "10.19.21.241:18087", "pid": 623}
2015/09/15 10:26:11 dashboard.go:144: [WARN] ********** Attention **********
2015/09/15 10:26:11 dashboard.go:145: [WARN] You should use `kill {pid}` rather than `kill -9 {pid}` to stop me,
2015/09/15 10:26:11 dashboard.go:146: [WARN] or the node resisted on zk will not be cleaned when I'm quiting and you must remove it manually
2015/09/15 10:26:11 dashboard.go:147: [WARN] *******************************</pre>
错误2:

删除group 下的节点被锁
<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-config server remove 2 10.19.21.241:6380
2015/09/15 10:29:41 main.go:153: [PANIC] run sub-command failed
[error]: http status code 500, zkutil: obtaining lock timed out
    4   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/utils.go:66
            main.callApi
    3   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/server_group.go:124
            main.runRemoveServerFromGroup
    2   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/server_group.go:57
            main.cmdServer
    1   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/main.go:86
            main.runCommand
    0   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/main.go:151
            main.main
        ... ...
[stack]: 
    0   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/main.go:153
            main.main
        ... ...
</pre>
同样到zk里删除整个db_test
<pre class="lang:sh decode:true ">[zk: localhost:2181(CONNECTED) 5] ls /zk/codis/db_test
[proxy, slots, servers, LOCK, migrate_tasks, actions, fence, ActionResponse, dashboard]
[zk: localhost:2181(CONNECTED) 6] delete /zk/codis/db_test
Node not empty: /zk/codis/db_test
</pre>
停止服务
<pre class="lang:sh decode:true ">[root@VM-241 codis]# ps -ef |grep codis
root       623 32515  0 10:26 pts/3    00:00:01 bin/codis-config -c config.ini dashboard
root      1663 32515  0 10:35 pts/3    00:00:00 grep codis
root     13115     1  0 Sep14 ?        00:00:42 bin/codis-server *:6379     
root     13134     1  0 Sep14 ?        00:00:42 bin/codis-server *:6380     
root     13210     1  0 Sep14 ?        00:00:41 bin/codis-server *:6480     
root     13229     1  0 Sep14 ?        00:00:41 bin/codis-server *:6479     
[root@VM-241 codis]# pkill codis
2015/09/15 10:35:29 dashboard.go:154: [INFO] removing dashboard node
2015/09/15 10:35:29 main.go:104: [PANIC] ctrl-c or SIGTERM found, exit
[stack]: 
    0   /usr/local/codis/src/github.com/wandoulabs/codis/cmd/cconfig/main.go:104
            main.func·010
        ... ...
[1]+  Exit 1                  bin/codis-config -c config.ini dashboard
[root@VM-241 codis]# ps -ef |grep codis
root      1694 32515  0 10:35 pts/3    00:00:00 grep codis</pre>
<pre class="lang:sh decode:true ">[root@VM-241 codis]# bin/codis-config action remove-lock
2015/09/15 10:50:29 action.go:331: [INFO] deleting../zk/codis/db_test/LOCK/lock-0000000038
{
  "msg": "OK",
  "ret": 0
}
[root@VM-241 codis]# bin/codis-config server list
[
  {
    "id": 1,
    "product_name": "test",
    "servers": [
      {
        "addr": "localhost:6380",
        "group_id": 1,
        "type": "slave"
      },
      {
        "addr": "localhost:6379",
        "group_id": 1,
        "type": "master"
      }
    ]
  },
  {
    "id": 2,
    "product_name": "test",
    "servers": [
      {
        "addr": "10.19.21.241:6380",
        "group_id": 2,
        "type": "offline"
      },
      {
        "addr": "localhost:6480",
        "group_id": 2,
        "type": "master"
      }
    ]
  }
]
[root@VM-241 codis]# bin/codis-config server remove 2 10.19.21.241:6380
2015/09/15 10:52:24 server_group.go:182: [INFO] {offline 2 10.19.21.241:6380}
{
  "msg": "OK",
  "ret": 0
}
[root@VM-241 codis]# bin/codis-config server list
[
  {
    "id": 1,
    "product_name": "test",
    "servers": [
      {
        "addr": "localhost:6380",
        "group_id": 1,
        "type": "slave"
      },
      {
        "addr": "localhost:6379",
        "group_id": 1,
        "type": "master"
      }
    ]
  },
  {
    "id": 2,
    "product_name": "test",
    "servers": [
      {
        "addr": "localhost:6480",
        "group_id": 2,
        "type": "master"
      }
    ]
  }
]
</pre>
&nbsp;

</div>
</div>
