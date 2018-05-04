---
title: zabbix2.4.4升级到2.5.0
tags:
  - zabbix-2.5.0
id: 58
categories:
  - Zabbix
date: 2015-09-08 18:26:36
---

<div>zabbix2.5发布于2015年8月19日，只发布了源码，需要更新的同学需要自己编译</div>
<div>更新安装时会有3.0的提示。请不要惊慌。2.5应该属于过渡版。</div>
<div>如果你是2.0版本可以升级，如果是低于2.0请升级到2.x然后再升级到2.5</div>
<!-- more -->
<div>下面是升级步骤：</div>
<div>1.关闭zabbix server服务</div>
<div>
<pre class="lang:sh decode:true"># /etc/init.d/zabbix_server stop</pre>
关闭服务防止新数据提交到数据导致数据不一致

2.备份数据库
<pre class="lang:sh decode:true"># mysqldump -uzabbix -pzabbix zabbix &gt; zabbix_bak.sql</pre>
<div>3.备份文件</div>
<div>
<pre class="lang:sh decode:true"># 7za a /usr/local/etc/zabbix* /app/zabbix /usr/local/bin/zabbix*</pre>
</div>
<div>备份配置文件，网站文件，二进制文件</div>
<div></div>
<div>
<div>4.安装新版zabbix</div>
<div></div>
<div>下载地址：http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Development/2.5.0/zabbix-2.5.0.tar.gz/download</div>
</div>
<div>
<pre class="lang:sh decode:true"># tar xf zabbix-2.5.0.tar.gz
# cd zabbix-2.5.0
# ./configure --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
# make install

拷贝网站文件
# cp -R frontends/php/* /app/zabbix</pre>
5.启动zabbix server服务
<pre class="lang:sh decode:true"># /etc/init.d/zabbix_server start</pre>
6.安装zabbix

![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150908-1@2x.jpg)![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150908-2@2x.jpg)![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150908-3@2x.jpg)![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150908-4@2x.jpg)![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150908-5@2x.jpg)![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150908-6@2x.jpg)

&nbsp;
<div>这个地方报错了，权限问题</div>
<div>chown www. /app/zabbix -R</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150908-7@2x.jpg)</div>
<div>
<div>完成安装后没有中文选项,需要修改配置文件</div>
<div>
<pre class="lang:sh decode:true"># vim /app/zabbix/include/locales.inc.php
'zh_CN' =&gt; array('name' =&gt; _('Chinese (zh_CN)'),        'display' =&gt; true),</pre>
修改中文乱码
<pre class="lang:sh decode:true "># cp simhei.ttf /app/zabbix/fonts/
# sed -i 's/DejaVuSans/simhei/g' /home/wwwroot/zabbix/include/defines.inc.php</pre>
升级后界面

![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150908-8@2x.jpg)

</div>
</div>
</div>
</div>
