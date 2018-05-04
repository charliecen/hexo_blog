---
title: ELK 使用中遇到的问题
date: 2017-10-16 03:32:54
tags:
  - elasticsearch
  - logstash
  - kibana
categories:
  - ELK
---


### 问题1

#### logstash 启动报错如下：

```sh
[2017-09-27T15:49:05,406][WARN ][logstash.inputs.file     ] failed to open /vol2/ZT2/170927-02/SessionServer-YP06/statobjscenesserver34.log.170927-02: Permission denied - /vol2/ZT2/170927-02/SessionServer-YP06/statobjscenesserver34.log.170927-02
[2017-09-27T15:49:05,407][WARN ][logstash.inputs.file     ] failed to open /vol2/ZT2/170927-02/SessionServer-YP06/statobjsessionserver.log.170927-02: Permission denied - /vol2/ZT2/170927-02/SessionServer-YP06/statobjsessionserver.log.170927-02

```
<!--more-->

#### 解决思路:

##### 方法1：错误描述很明显是权限问题

```sh
$ chmod 777 /vol2/ -R
```

##### 方法2：但是问题没有得到解决, 后来网上搜到说是系统设定允许打开文档数问题

```sh
$ ulimit -n
2048

# 修改配置
$ vim /etc/security/limits.conf
*                soft   nofile          1048576
*                hard   nofile          1048576
```
保存后，退出重新登录后生效

```sh
$ ulimit -n
1048576
```

> 注意： linux 默认上线为2^20=1048576, 千万不能超过该数值，否则系统重启导致无法登录

##### 方法3：尝试查看配置文件，测试`gork` 得出正则不匹配导致的，所以首先去匹配正则

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lsXE35q2Pmm47CIuPpRbSITnEaPI.jpeg)

修改配置文件

```conf

filter {
  grok {
    match => ["path", "/vol2\/(?<game_name>\w+|\w+\d+?)\/(?<time>\d{6}-\d{2}?)\/(?<server_name>\w+\d{2}?)\-(?<zone>\w+\d+?)|\-(\.*)\/(\.*)"]
  }
```

### 问题2

#### 报错信息：

```sh
[logstash.inputs.file     ] Reached open files limit: 4095, set by the 'max_open_files' option or default, files yet to open: 158390
```

#### 解决办法：

修改配置文件，允许打开文件数

```conf
file {
	# 路劲下目录递归查找所有文件
    path => "/vol2/**/*"
    # 打开文件数
    max_open_files => 200000
  }
```

### 问题3

#### 问题描述：

`elasticsarch` 无法发现 `logstash` 收集到的日志。

```sh
$ curl http://10.21.16.49:9200 -u user:password
{
  "name" : "sUOfDTU",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "48mAG5SaTAuI-ajfh5cPxw",
  "version" : {
    "number" : "5.6.0",
    "build_hash" : "781a835",
    "build_date" : "2017-09-07T03:09:58.087Z",
    "build_snapshot" : false,
    "lucene_version" : "6.6.0"
  },
  "tagline" : "You Know, for Search"
}
```

连接测试正常

又创建个新配置文件如下：

```conf
output {
  elasticsearch {
    hosts => ["10.21.16.49:9200"]
    user => "user"
    password => "password"
    index => "159-%{+YYYY.MM.dd}"
  }
  stdout {
    codec => rubydebug
  }
}
```

`elasticsearch` 可以发现 `logstash`收集到日志

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lrRpnLWY7Zgpqv35XKhb2AZKEhzG.jpeg)

对比两个配置文件，发现只有`index`不同外，其他都一样，所以查找这里的问题。

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lgTw8qE4sMK484IrUkJWy72mpG9T.jpeg)

由于我的`index`使用了变量，导致`index`这里无法创建，所以修改配置如下：

```conf
mutate {
  # 关联索引名的变量都转成小写字符
  lowercase => ["game_name", "server_name", "zone"]
}
```

#### 结果：

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lrRXfLp5YiO50gCcuR5hbOaSniPh.jpeg)

### 问题4

#### 报错信息：

```sh
[2017-09-28T13:33:48,415][INFO ][logstash.outputs.elasticsearch] retrying failed action with response code: 429 ({"type"=>"es_rejected_execution_exception", "reason"=>"rejected execution of org.elasticsearch.transport.TransportService$7@660c4c58 on EsThreadPoolExecutor[bulk, queue capacity = 200, org.elasticsearch.common.util.concurrent.EsThreadPoolExecutor@542fa472[Running, pool size = 32, active threads = 32, queued tasks = 200, completed tasks = 5705638]]"})
[2017-09-28T13:33:48,415][INFO ][logstash.outputs.elasticsearch] Retrying individual bulk actions that failed or were rejected by the previous bulk request. {:count=>60}
```

由于`elasticsearch`写入遇到瓶颈导致，首先想到是调整`elasticsearch`线程池， [官网建议](https://www.elastic.co/guide/cn/elasticsearch/guide/current/dont-touch-these-settings.html) ，于是我们修改`logstash`参数 `pipeline.batch.size`

在ES5.0以后，es将`bulk`、`flush`、`get`、`index`、`search`等线程池完全分离，自身的写入不会影响其他功能的性能。 
来查询一下ES当前的线程情况：

```sh
GET _nodes/stats/thread_pool?pretty
```

```js
"thread_pool": {
	"bulk": {
	  "threads": 32,
	  "queue": 121,
	  "active": 32,
	  "rejected": 516,
	  "largest": 32,
	  "completed": 5813431
	},
```

其中：`bulk`模板的线程数32，当前活跃的线程数32，证明所有的线程是busy的状态，queue队列121，rejected为516。那么问题就找到了，所有的线程都在忙，队列堵满后再有进程写入就会被拒绝，而当前拒绝数为516。

#### 解决方案：

官方的建议是提高每次批处理的数量，调节传输间歇时间。当前`batch.size`增大，es处理的事件数就会变少，写入也就愉快了。

```sh
$ vim config/logstash.yml

pipeline.workers: 32
pipeline.output.workers: 32
pipeline.batch.size: 100000
pipeline.batch.delay: 10
```

#### 参数解析：

`worker`,`output.workers`数量建议等于CPU数

`batch.size` 一般指数据的条目数。考虑网卡流量，磁盘转速的问题，所以一般来说，建议 bulk 请求体的大小，在 15MB 左右，通过实际测试继续向上探索最合适的设置。

以 `logstash` 默认的 `bulk_size => 5000` 为例，假设单条数据平均大小 200B ，一次 `bulk` 请求体的大小就是 1.5MB。那么我们可以尝试 `bulk_size => 50000`；而如果单条数据平均大小是 20KB，一次 `bulk` 大小就是 100MB，显然超标了，需要尝试下调至 `bulk_size => 500`。

`batch.delay`根据实际的数据量逐渐增大来测试最优值。

#### 结果：

![file](http://7xlxn7.com1.z0.glb.clouddn.com/ljwrJ-BgJ8yp5f7GJP-8HfcOSFCW.jpeg)

### 问题4

错误描述：

```sh
[2017-10-12T14:48:32,179][WARN ][o.e.b.JNANatives         ] Unable to lock JVM Memory: error=12, reason=无法分配内存
[2017-10-12T14:48:32,181][WARN ][o.e.b.JNANatives         ] This can result in part of the JVM being swapped out.
[2017-10-12T14:48:32,182][WARN ][o.e.b.JNANatives         ] Increase RLIMIT_MEMLOCK, soft limit: 65536, hard limit: 65536
[2017-10-12T14:48:32,182][WARN ][o.e.b.JNANatives         ] These can be adjusted by modifying /etc/security/limits.conf, for example:
	# allow user 'elk' mlockall
	elk soft memlock unlimited
	elk hard memlock unlimited
[2017-10-12T14:48:32,182][WARN ][o.e.b.JNANatives         ] If you are logged in interactively, you will have to re-login for the new limits to take effect.
[2017-10-12T14:48:32,346][INFO ][o.e.n.Node               ] [master2] initializing ...
[2017-10-12T14:48:32,432][INFO ][o.e.e.NodeEnvironment    ] [master2] using [1] data paths, mounts [[/ (/dev/sda3)]], net usable_space [1.7tb], net total_space [2tb], spins? [possibly], types [ext4]
[2017-10-12T14:48:32,432][INFO ][o.e.e.NodeEnvironment    ] [master2] heap size [31.7gb], compressed ordinary object pointers [false]
[2017-10-12T14:48:32,433][INFO ][o.e.n.Node               ] [master2] node name [master2], node ID [RunwGa2wS4mMZW_03-kTbQ]
[2017-10-12T14:48:32,434][INFO ][o.e.n.Node               ] [master2] version[5.6.0], pid[42846], build[781a835/2017-09-07T03:09:58.087Z], OS[Linux/2.6.32-358.el6.x86_64/amd64], JVM[Oracle Corporation/Java HotSpot(TM) 64-Bit Server VM/1.8.0_144/25.144-b01]
[2017-10-12T14:48:32,434][INFO ][o.e.n.Node               ] [master2] JVM arguments [-Xms32g, -Xmx32g, -XX:+UseConcMarkSweepGC, -XX:CMSInitiatingOccupancyFraction=75, -XX:+UseCMSInitiatingOccupancyOnly, -XX:+AlwaysPreTouch, -Xss10m, -Djava.awt.headless=true, -Dfile.encoding=UTF-8, -Djna.nosys=true, -Djdk.io.permissionsUseCanonicalPath=true, -Dio.netty.noUnsafe=true, -Dio.netty.noKeySetOptimization=true, -Dio.netty.recycler.maxCapacityPerThread=0, -Dlog4j.shutdownHookEnabled=false, -Dlog4j2.disable.jmx=true, -Dlog4j.skipJansi=true, -XX:+HeapDumpOnOutOfMemoryError, -Des.path.home=/usr/local/src/elasticsearch-5.6.0]
[2017-10-12T14:48:33,816][INFO ][o.e.p.PluginsService     ] [master2] loaded module [aggs-matrix-stats]
[2017-10-12T14:48:33,816][INFO ][o.e.p.PluginsService     ] [master2] loaded module [ingest-common]
[2017-10-12T14:48:33,816][INFO ][o.e.p.PluginsService     ] [master2] loaded module [lang-expression]
[2017-10-12T14:48:33,816][INFO ][o.e.p.PluginsService     ] [master2] loaded module [lang-groovy]
[2017-10-12T14:48:33,816][INFO ][o.e.p.PluginsService     ] [master2] loaded module [lang-mustache]
[2017-10-12T14:48:33,816][INFO ][o.e.p.PluginsService     ] [master2] loaded module [lang-painless]
[2017-10-12T14:48:33,817][INFO ][o.e.p.PluginsService     ] [master2] loaded module [parent-join]
[2017-10-12T14:48:33,817][INFO ][o.e.p.PluginsService     ] [master2] loaded module [percolator]
[2017-10-12T14:48:33,817][INFO ][o.e.p.PluginsService     ] [master2] loaded module [reindex]
[2017-10-12T14:48:33,817][INFO ][o.e.p.PluginsService     ] [master2] loaded module [transport-netty3]
[2017-10-12T14:48:33,817][INFO ][o.e.p.PluginsService     ] [master2] loaded module [transport-netty4]
[2017-10-12T14:48:33,817][INFO ][o.e.p.PluginsService     ] [master2] loaded plugin [x-pack]
[2017-10-12T14:48:35,165][DEBUG][o.e.a.ActionModule       ] Using REST wrapper from plugin org.elasticsearch.xpack.XPackPlugin
[2017-10-12T14:48:36,343][INFO ][o.e.x.m.j.p.l.CppLogMessageHandler] [controller/42972] [Main.cc@128] controller (64 bit): Version 5.6.0 (Build 93aea61f57f7d8) Copyright (c) 2017 Elasticsearch BV
[2017-10-12T14:48:36,452][INFO ][o.e.d.DiscoveryModule    ] [master2] using discovery type [zen]
[2017-10-12T14:48:37,590][INFO ][o.e.n.Node               ] [master2] initialized
[2017-10-12T14:48:37,590][INFO ][o.e.n.Node               ] [master2] starting ...
[2017-10-12T14:48:38,175][INFO ][o.e.t.TransportService   ] [master2] publish_address {10.211.45.67:9300}, bound_addresses {[::]:9300}
[2017-10-12T14:48:38,182][INFO ][o.e.b.BootstrapChecks    ] [master2] bound or publishing to a non-loopback or non-link-local address, enforcing bootstrap checks
ERROR: [1] bootstrap checks failed
[1]: memory locking requested for elasticsearch process but memory is not locked
[2017-10-12T14:48:38,191][INFO ][o.e.n.Node               ] [master2] stopping ...
[2017-10-12T14:48:38,472][INFO ][o.e.n.Node               ] [master2] stopped
[2017-10-12T14:48:38,473][INFO ][o.e.n.Node               ] [master2] closing ...
[2017-10-12T14:48:38,482][INFO ][o.e.n.Node               ] [master2] closed

```

由于在`elasticsearch.yml` 启用`bootstrap.mlockall: true`. 设置为true来锁住内存，因为当JVM开始swapping的时候Elasticsearch的效率会降低，所以要保证他不被swap，可以吧ES_MIN_MEN和ES_MAX_MEN两个环境变量设置为同一个值，并且保证机器有足够的内存分配给Elasticsearch，同时也要允许Elasticsearch的进程可以锁住内存，linux下可以通过`ulimit -l unlimited`命令。

解决办法：

#### 查看es节点是否开启了mem_lock

```sh
GET /_nodes?filter_path=**.mlockall
```

```sh
{
  "nodes": {
    "IatP7izzS9WwvawIt839mQ": {
      "process": {
        "mlockall": false
      }
    },
    "LKuZugkFQpqxg2eMoUA7sg": {
      "process": {
        "mlockall": false
      }
    },
    "zTiTg4gPSnC3h_7_asiGIA": {
      "process": {
        "mlockall": false
      }
    },
    "Y5wa24dEQaunz7WVkMs7FA": {
      "process": {
        "mlockall": false
      }
    }
  }
}
```

上述返回内容，可见都没有开启mem_lock，集全随时都可能发生故障（尤其是集群正常运行了一段时间，莫名其妙的故障）

#### 分配内存无限制

```sh
# 告诉操作系统可以无限制分配内存给一个进程
$ ulimit -l unlimited
```

#### 最后添加到配置文件中

```sh
$ vim /etc/security/limits.conf
# allow user 'elk' mlockall
elk soft memlock unlimited
elk hard memlock unlimited
```

启动服务后正常

### 错误5

#### 问题描述：

由于系统宕机，导致大量索引出现了Unassigned 状态。我们通过reroute API进行了操作，对主分片缺失的索引

查看集群健康状态

```sh
GET /_cluster/health
```

```
{
  "cluster_name": "ztgame-elk",
  "status": "yellow",
  "timed_out": false,
  "number_of_nodes": 4,
  "number_of_data_nodes": 3,
  "active_primary_shards": 5693,
  "active_shards": 9951,
  "relocating_shards": 0,
  "initializing_shards": 2,
  "unassigned_shards": 1434,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 2,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 170,
  "active_shards_percent_as_number": 87.38912795292877
}
```

查看为分配的shard

```sh
GET _cat/shards?v
```

```sh
index                             shard prirep state
yp_zg_171012-00_yp35              2     r      UNASSIGNED                                   
yp_zg_171012-00_yp35              4     r      UNASSIGNED                                   
yp_zg_171012-00_yp35              0     r      UNASSIGNED                                   
```

执行恢复语句

```sh
POST /_cluster/reroute
{
	"commands": [ 
		{
  			"allocate_replica": {
    			"index": "yp_zg_171012-00_yp35",
    			"shard": 0,
    			"node": "slave1"
  			}
		}
	]
}
```

如果有太多未分配可以写脚本执行：

```sh
#!/bin/bash

user='elastic'
pass='changeme'
url='http://localhost:9200'
file="./indices.txt"

# 获取未分配的shard
curl -s -u $user:$pass $url/_cat/shards |grep UNASSIGNED  > $file

# 恢复的节点名
arr=(master1 master2)

# 循环读取文件
while read line
do
        index=`echo $line |awk '{print $1}'`
        shard=`echo $line |awk '{print $2}'`
        for i in ${arr[@]};do
	        curl -XPOST -u $user:$pass $url/_cluster/reroute -d '{
	                "commands": [ {
	                        "allocate_replica": {
	                                "index": "'$index'",
	                                "shard": "'$shard'",
	                                "node": "'${i}'"
	                        }
	                } ]
	        }'
        done
        sleep 3
done < $file
```

当然还有其他办法恢复，具体详情请借鉴[这里](http://www.jianshu.com/p/542ed5a5bdfc)
