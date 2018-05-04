---
title: Logstash 过滤日志
tags:
  - logstash
  - filter
  - ruby
  - remove_field
categories:
  - ELK
  - Linux
---

### Logstash 过滤日志

#### 输出匹配的内容

配置文件如下：

```sh
$ vim config/test.conf

input { 
    file {
        path => ["/var/log/test/test.log"]
        max_open_files => 20000
    }
}

filter {
    grok {
        # 添加标签
        add_tag => [ "valid" ]
        # 匹配"ERROR" 或者 "DEBUG"
        match => [
            "message"   =>  "ERROR",
            "message"   =>  "DEBUG"
        ]
    }
    
    # 无效的删除
    if "valid" not in [tags] {
        drop {}
    }
    
}

output {
    stdout {
        codec => rubydebug
    }
}

```

<!-- more -->
测试如下：

```sh
$ sudo echo "180502-14:55:13 money[26]" >> test.log
$ sudo echo "180502-14:55:13 ERROR:" >> test.log

# 结果
 bin/logstash -f config/test.conf
Sending Logstash's logs to /charlie/elk/logstash-5.6.0/logs which is now configured via log4j2.properties
[2018-05-03T14:39:39,138][INFO ][logstash.modules.scaffold] Initializing module {:module_name=>"fb_apache", :directory=>"/charlie/elk/logstash-5.6.0/modules/fb_apache/configuration"}
[2018-05-03T14:39:39,161][INFO ][logstash.modules.scaffold] Initializing module {:module_name=>"netflow", :directory=>"/charlie/elk/logstash-5.6.0/modules/netflow/configuration"}
[2018-05-03T14:39:40,656][INFO ][logstash.pipeline        ] Starting pipeline {"id"=>"main", "pipeline.workers"=>4, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>5, "pipeline.max_inflight"=>500}
[2018-05-03T14:39:40,958][INFO ][logstash.pipeline        ] Pipeline main started
[2018-05-03T14:39:41,049][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
{
       "path" => "/var/log/test/test.log",
    "logdate" => 2018-05-02T06:55:13.000Z,
       "host" => "macmini-bbcdfa.ztgame.com",
    "message" => [
        [0] "180502-14:55:13",
        [1] "ERROR:"
    ]
}
```

#### 分割日志并去除无效的字段

配置文件如下：

```sh
$ vim config/test.conf

input {
  file {
    path => ["/var/log/test/test.log"]
    max_open_files => 20000
  }
}

filter {
    #grok {
    #  match => ["path", "/vol2\/(?<game_name>\w+|\w+\d+?)\/(?<time>\d{6}-\d{2}?)\/(?<server_name>\w+?)\-(?<zone>\w+\d+?)|\-(\.*)"]
    #  match => ["path", "/vol2\/(?<game_name>\w+|\w+\d+?)\/(?<time>\d{6}-\d{2}?)\/(?<server_name>\w+?)\-(?<zone>\w+\d+?)\-(?<server_type>\w+?)\/(?<logname>\w+?)\.(.*)"]
    #}
    # 丢弃日志
    if [logname] == "sobjscenesserver26" {
        drop{}
    }
    # 匹配有效的字段
    grok {
        add_tag => [ "valid" ]
        match => [
            "message", "ERROR:",
            "message", "DEBUG:"
        ]
    }
    # 丢弃无效的日志
    if "valid" not in [tags] {
        drop {  }
    }
    # 匹配以日期开头的日志
    if [message] =~ /^(\d{6}-\d{2}:\d{2}:\d{2})/ {
        # 以空格分割日志，并添加字段
        mutate {
            split => ["message", " "]
            add_field => {
                "logdate" => "%{[message][0]}"
            }
        }
        # 数组迭代去除"|",覆盖到原数组
        ruby {
            code => "
                values = event.get('message')
                #File.open('/charlie/elk/logstash-5.6.0/output.txt', 'w')  { |file| file.write(values) }
                values.each do |v|
                    if v == '|'
                        values.delete(v)
                    end
                end
                event.set('message', values)
            "
        }
        # 去除无效字段
        mutate {
            remove_field => ["@timestamp", "@version", "tags"]
        }
        # 日期格式
        date {
            match => ["logdate", "yyMMdd-HH:mm:ss"]
            target => "logdate"
        }
    } else {
        drop {}
    }
}

output {
  stdout {
    codec => rubydebug
  }
}
```

测试效果如下：

```sh
$ sudo echo "180502-14:55:13 ERROR: | aa bb cc | dd 0 |" >> test.log

{
       "path" => "/var/log/test/test.log",
    "logdate" => 2018-05-02T06:55:13.000Z,
       "host" => "macmini-bbcdfa.ztgame.com",
    "message" => [
        [0] "180502-14:55:13",
        [1] "ERROR:",
        [2] "aa",
        [3] "bb",
        [4] "cc",
        [5] "dd",
        [6] "0"
    ]
}

```
