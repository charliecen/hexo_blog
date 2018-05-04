---
title: ELK 安装配置
date: 2017-09-19 07:39:54
tags:
  - logstash
  - elasticsearch
  - kibana
categories:
  - Linux
---

### 下载安装包

[下载地址](https://www.elastic.co/cn/downloads) 

当前版本使用的全部是 5.6.0

### 配置

#### elasticsearch 配置

```sh
$ tar xf elasticsearch-5.6.0.tar.gz
$ cd  elasticsearch-5.6.0
$ vim config/jvm.options
# 根据自己的服务器的内存定义此大小
-Xms32g
-Xmx32g
```
<!--more-->

> 注意： 由于运行`elasticsearch` 需要普通用户，所以这里要创建个普通用户

```sh
$ useradd elk
$ su elk
# 启动服务
$ bin/elasticseach
```
测试

```sh
$ curl http://127.0.0.1:9200 -u admin:xxxxxx
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

#### logstash 配置

```sh
$ tar xf logstash-5.6.0.tar.gz
$ cd logstash-5.6.0
$ vim config/logstash.yml
# 启用转义符, 由于日志的字段不同，所以我需要先用"\t"分割，然后用" "分割，具体操作，下面有详细配置
config.support_escapes: true

$ vim conf/logstash.conf
input {
  file {
    #path => "/var/log/xx/useract_server.log*"
    # 文件源
    path => "/10.29.212.58/00-00-ac-1d-d4-3a/tmp/AppServer06-XX2/log/useract_server.log*"
  }
}

filter {
  grok {
    # 匹配文件名
    match => ["path", "(?<filename>useract_server.log.\d{6}-\d{2}$)"]
  }
  # 分割后添加字段
  mutate {
     split => ["message", "\t"]
     add_field => {
       "tmp" => "%{[message][0]}"
     }
     add_field => {
       "accid" => "%{[message][1]}"
     }
     add_field => {
       "user_control_obj_type" => "%{[message][2]}"
     }
     add_field => {
       "charid" => "%{[message][3]}"
     }
     add_field => {
       "char_name" => "%{[message][4]}"
     }
     add_field => {
       "number_ip" => "%{[message][5]}"
     }
     add_field => {
       "level" => "%{[message][6]}"
     }
     add_field => {
       "zone_id" => "%{[message][7]}"
     }
     add_field => {
       "one_level_camp" => "%{[message][8]}"
     }
     add_field => {
       "map_name" => "%{[message][9]}"
     }
     add_field => {
       "map_detail" => "%{[message][10]}"
     }
     add_field => {
       "x_coord" => "%{[message][11]}"
     }
     add_field => {
       "y_coord" => "%{[message][12]}"
     }
     add_field => {
       "z_coord" => "%{[message][13]}"
     }
     add_field => {
       "operation_type" => "%{[message][14]}"
     }
     add_field => {
       "operation_way" => "%{[message][15]}"
     }
     add_field => {
       "operation_detail" => "%{[message][16]}"
     }
     add_field => {
       "cluster_server_id" => "%{[message][17]}"
     }
     add_field => {
       "result_object_type" => "%{[message][18]}"
     }
     add_field => {
       "result_object_id" => "%{[message][-5]}"
     }
     add_field => {
       "result_object_name" => "%{[message][-4]}"
     }
     add_field => {
       "result_object_detail" => "%{[message][-3]}"
     }
     add_field => {
       "result_type" => "%{[message][-2]}"
     }
     add_field => {
       "result_count" => "%{[message][-1]}"
     }
   }
   mutate {
     split => ["tmp", " "]
     add_field => {
       "logdate" => "%{[tmp][0]}"
     }
     add_field => {
       "game_id" => "%{[tmp][2]}"
     }
   }
  # 转换字段类型
  mutate {
    convert => {
      "accid" => "integer"
      "user_control_obj_type" => "integer"
      "charid" => "integer"
      "number_ip" => "integer"
      "level" => "integer"
      "zone_id"	=> "integer"
      "one_level_camp" => "integer"
      "x_coord"	=> "integer"
      "y_coord"	=> "integer"
      "z_coord"	=> "integer"
      "cluster_server_id"	=> "integer"
      "result_object_type"	=> "integer"
      "result_object_id"	=> "integer"
      "result_type"	=> "integer"
      "result_count"	=> "integer"
    }
  }
  # 日期格式
  date {
    match => ["logdate", "yyMMdd-HH:mm:ss"]
    target => "logdate"
  }
}

# 输出到es, 由于安装了x-pack插件，所以配置了用户和密码
output {
  elasticsearch {
    hosts => ["127.0.0.1:9200"]
    user => "admin"
    password => "xxxxxx"
    # 自定义索引名
    index => "xx2-%{filename}"
  }
  #stdout {
  #  codec => rubydebug
  #}
}

# 启动服务

$ bin/logstash -f config/logstash.conf
```

#### kibana配置

```sh
$ tar xf kibana-5.6.0-linux-x86_64.tar.gz
$ cd cd kibana-5.6.0-linux-x86_64
$ vim config/kibana.yml
server.host: 0.0.0.0
elasticsearch.url: "http://127.0.0.1:9200"

# 启动服务
$ bin/kibana
```

#### 安装x-pack插件

由于安装太慢，所以这里翻墙后下载后，上传到服务器里

```sh
$ wget https://artifacts.elastic.co/downloads/kibana-plugins/x-pack/x-pack-5.6.0.zip
```

>注意：集群中的每台 Elasticsearch 都是需要安装的，  Kibana服务器上也同样需要安装

```sh
$ bin//elasticsearch-plugin install /usr/local/src/x-pack-5.6.0.zip

$ bin/kibana-plugin install /usr/local/src/x-pack-5.6.0.zip
```

### 页面设置

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lkvlcN6Fb9fMfE7ZbRKC9XcC-0Gp.jpeg)

登录账号默认用户`elastic`, 默认密码`changeme`,登录后建议修改密码。

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lkU9rWE5ydCrouiT8V96YHAza85f.jpeg)

创建Index

![file](http://7xlxn7.com1.z0.glb.clouddn.com/llc5laxnQxEqcFIYTnk1k2kVrv2c.jpeg)

发现数据

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lmFHpZI9UsAI8NZIaBrrbkfXnWFl.jpeg)

### supervisord配置

使用supervisord管理服务

```sh
$ yum install -y supervisord

# 配置
$ vim /etc/supervisord.conf

[program:logstash]
command = /usr/local/src/logstash-5.6.0/bin/logstash -f /usr/local/src/logstash-5.6.0/config/logstash.conf -w 40 -b 2000
autostart = true
autorestart = true
startsecs = 5
startretries = 3
user = root
redirect_stderr = true
stdout_logfile = /var/log/elk/logstash-std.log
stderr_logfile = /var/log/elk/logstash-err.log

[program:elasticsearch]
command=/usr/local/src/elasticsearch-5.6.0/bin/elasticsearch
autostart = true
autorestart = true
startsecs = 5
startretries = 3
user = elk
redirect_stderr = true
stdout_logfile = /var/log/elk/elasticsearch-std.log
stderr_logfile = /var/log/elk/elasticsearch-err.log

[program:kibana]
command=/usr/local/src/kibana-5.6.0-linux-x86_64/bin/kibana
autostart = true
autorestart = true
startsecs = 5
startretries = 3
user = root
redirect_stderr = true
stdout_logfile = /var/log/elk/kibana-std.log
stderr_logfile = /var/log/elk/kibana-err.log
```

启动服务

```sh
$ /etc/init.d/supervisord start
$ supervisorctl status
elasticsearch  RUNNING    pid 87134, uptime 4:31:22
kibana             RUNNING    pid 87136, uptime 4:31:22
logstash          RUNNING    pid 87135, uptime 4:31:22
```