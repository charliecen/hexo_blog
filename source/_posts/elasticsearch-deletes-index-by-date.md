---
title: elasticsearch 按日期定时删除索引
date: 2017-11-07 08:31:26
tags:
  - elasticsearch
  - elk
  - indices
  - delete index
categories:
  - ELK

---

由于`elk`每天每时每刻都在创建索引文件，导致磁盘容量越来越小，所以要进行定期删除

### 官网查询删除

```js
curl -u 用户名:密码  -H'Content-Type:application/json' -d'{
    "query": {
        "range": {
            "@timestamp": {
                "lt": "now-7d",
                "format": "epoch_millis"
            }
        }
    }
}
' -XPOST "http://127.0.0.1:9200/*-*/_delete_by_query?pretty"
```

<!--more-->

> 注释:
> 
> -u 是格式为`userName:password`，使用`Basic Auth`进行登录。如果`elasticsearch`没有使用类似`x-pack`进行安全登录，则不需要加-u参数

>-H 是指定文档类型是`json`格式

>-XPOST 是指定用`POST`方式请求

>-d 是指定`body`内容

```js
{
    "query": {
        "range": { //范围
            "@timestamp": {//时间字段
                "lt": "now-7d",//lt是小于(<)，lte是小于等于(<=),gt是大于(>),gte是大于等于(>=),now-7d是当前时间减7天
                "format": "epoch_millis"
            }
        }
    }
}
```

计划任务

```sh
$ crontab -e
# 每天0点删除超过7天的无效索引
* 0 * * * /usr/bin/curl -u username:password  -H'Content-Type:application/json' -d'{"query":{"range":{"@timestamp":{"lt":"now-7d","format":"epoch_millis"}}}}' -XPOST "http://127.0.0.1:9200/*-*/_delete_by_query?pretty" > /var/log/delete_index.log
```

优点：

1. 不依赖第三方插件或者代码

2. 简单易理解

3. 不需要指定索引名称可用*通配符删除

缺点：

1. 效率低

### 脚本删除

```sh
#!/bin/bash

indexPrefix=(yp zh jd)
elastic_url=127.0.0.1
elastic_port=9200
user="username"
pass="password"
log="/var/log/delete_index.log"

# 转化为时间戳， $1 为日期， $2 为时间
date2stamp () {
    date -d "$1 $2" +%s
}

# 当前日期时间戳减去索引名时间转化时间戳是否大于1
dateDiff (){
    case $1 in
        -s)   sec=1;      shift;;
        -m)   sec=60;     shift;;
        -h)   sec=3600;   shift;;
        -d)   sec=86400;  shift;;
        -2d)  sec=172800;  shift;;
        -5d)  sec=432000;  shift;;
        *)    sec=86400;;
    esac
    dte1=$(date2stamp $1)
    dte2=$(date2stamp $2)
    diffSec=$((dte2-dte1))
    if ((diffSec < 0)); then abs=-1; else abs=1; fi
    echo $((diffSec/sec*abs))
}


# 根据不同服务器，删除保存不同时间段的索引文件
for zone in ${indexPrefix[@]}; do
	# 循环获取索引文件，通过正则匹配过滤
	for index in $(curl -s -u $user:$pass "${elastic_url}:${elastic_port}/_cat/indices?v" |grep -E "${zone}_[A-Za-z0-9]{1,}_[0-9]{6}-[0-9]{2}" | awk '{print $3 }'); do
		# 获取索引文件日期，并转化格式
		date=$(echo ${index: -9}:00:00 |sed -n 's/-/ /p')
		# 获取当前日期
  		cond=$(date '+%Y-%m-%d %H:00:00')
		# 根据不同服务器，计算不同数值
		if [ ${zone} == 'zh' ]; then
  			diff=$(dateDiff -d "${date}" "${cond}")
		else
			diff=$(dateDiff -2d "${date}" "${cond}")
		fi
		# 打印索引名和结果数值
  		#echo -n "${index} (${diff})"

		# 判断结果值是否大于等于1
  		if [ $diff -ge 1 ]; then
    			curl -XDELETE -s -u $user:$pass "${elastic_url}:${elastic_port}/${index}" && echo "${index} 删除成功" >> $log || echo "${index} 删除失败" >> $log
		fi
	done
done
```

结果：

```sh
[2017-11-07T15:58:42,711][INFO ][o.e.c.m.MetaDataDeleteIndexService] [master1] [yp_zg_171105-16/F0MPnZ27TSGlgyP3RC5Z7w] deleting index
[2017-11-07T15:58:44,966][INFO ][o.e.c.m.MetaDataDeleteIndexService] [master1] [yp_xxsj_171105-16/V2ZCKKJMSJq_oWVTky7OFw] deleting index
[2017-11-07T15:58:55,621][INFO ][o.e.c.m.MetaDataDeleteIndexService] [master1] [zh_king3_171106-16/_ow8ZVGyQfm9NzRkVzHzsg] deleting index
[2017-11-07T15:58:57,536][INFO ][o.e.c.m.MetaDataDeleteIndexService] [master1] [zh_ztgame_171106-16/jS7E4wIXTPmR1dpAlyHT0Q] deleting index
[2017-11-07T15:58:59,933][INFO ][o.e.c.m.MetaDataDeleteIndexService] [master1] [zh_360_171106-16/GSV0Ptg4Qxy6UPgbNRrWmw] deleting index
[2017-11-07T15:59:02,087][INFO ][o.e.c.m.MetaDataDeleteIndexService] [master1] [zh_lzsy_171106-16/yM66fjQ9RT69aIHvnW8_5Q] deleting index
[2017-11-07T15:59:04,589][INFO ][o.e.c.m.MetaDataDeleteIndexService] [master1] [zh_giant_171106-16/3EvgRU34QqKjQ-WZSDzfxg] deleting index
```


