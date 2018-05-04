---
title: ELK中展示用户位置
tags:
  - geoip
  - kibana
id: 675
categories:
  - Elasticsearch
  - Kibana
  - Logstash
date: 2015-10-29 17:50:43
---

GeoIP 是最常见的免费 IP 地址归类查询库，同时也有收费版可以采购。GeoIP 库可以根据 IP 地址提供对应的地域信息，包括国别，省市，经纬度等，对于可视化地图和区域统计非常有用。
<!-- more -->
首先下载地图库
<pre class="lang:sh decode:true ">[root@monitor src]# curl -O http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz</pre>
解压并移动到指定目录
<pre class="lang:sh decode:true ">[root@monitor src]# gunzip GeoLiteCity.dat.gz 
[root@monitor src]# mv GeoLiteCity.dat  /opt/logstash/vendor/geoip/</pre>
编辑配置文件，filter里更改为如下内容：
<pre class="lang:sh decode:true ">  if [type] == "nginx" {
    grok {
      match =&gt; { "message" =&gt; "%{NGINXACCESS}" }
    }
    geoip {
      source =&gt; "remote_addr"
      target =&gt; "geoip"
      database =&gt; "/opt/logstash/vendor/geoip/GeoLiteCity.dat"
      add_field =&gt; [ "[geoip][coordinates]", "%{[geoip][longitude]}" ]
      add_field =&gt; [ "[geoip][coordinates]", "%{[geoip][latitude]}"  ]
      remove_field =&gt; [ "[geoip][latitude]", "[geoip][longitude]" ]
    }
    mutate {
      convert =&gt; [ "[geoip][coordinates]", "float"]
    }
  }</pre>
重启logstash服务
<pre class="lang:sh decode:true ">[root@monitor geoip]# /etc/init.d/logstash restart
Killing logstash (pid 29959) with SIGTERM
Waiting logstash (pid 29959) to die...
Waiting logstash (pid 29959) to die...
logstash stopped.
logstash started.</pre>
打开浏览器，查看日志新加入的field

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151029-0@2x.png)

创建可视化

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151029-1@2x.png)
