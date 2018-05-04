---
title: zabbix使用微信报警
tags:
  - weixin
  - zabbix
id: 594
categories:
  - Zabbix
date: 2015-10-15 14:16:14
---

### 1.注册微信公众号

<div>首先到微信公众平台[https://mp.weixin.qq.com](https://mp.weixin.qq.com)申请</div>
<div>然后登录，手机客户端扫描二维码，并加关注就可以了</div>
<div>然后就可以看到用户数</div>
<!-- more -->
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-7@2x.png)</div>
<div>点击用户数，并点击用户，可以看到用户的tofakeid，这个ID就是zabbix将发送报警信息到这个账号。</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-10@2x.png)</div>
<div>可以在URL里看到这个ID</div>
<div>[https://mp.weixin.qq.com/cgi-bin/singlesendpage?tofakeid=<span style="color: #ff0000;">353131080</span>&amp;t=message/send&amp;action=index&amp;token=1007714535&amp;lang=zh_CN](https://mp.weixin.qq.com/cgi-bin/singlesendpage?tofakeid=353131080&amp;t=message/send&amp;action=index&amp;token=1007714535&amp;lang=zh_CN)</div>
</div>

### 2.下载微信公众平台私有接口

<div></div>

#### 2.1 进入zabbix报警目录，下载文件

<pre class="lang:sh decode:true ">[root@monitor ~]# cd /usr/local/share/zabbix/alertscripts
[root@monitor alertscripts]# git clone https://github.com/lealife/WeiXin-Private-API
Initialized empty Git repository in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/.git/
remote: Counting objects: 172, done.
remote: Total 172 (delta 0), reused 0 (delta 0), pack-reused 172
Receiving objects: 100% (172/172), 36.94 KiB, done.
Resolving deltas: 100% (72/72), done.</pre>

#### 2.2 修改配置文件

<pre class="lang:sh decode:true">[root@monitor alertscripts]# vim WeiXin-Private-API/config.php

&lt;?php

// 全局配置

$G_ROOT = dirname(__FILE__);

$G_CONFIG["weiXin"] = array(
        'account' =&gt; '微信公众登录账号',
        'password' =&gt; '微信公众登录密码',
        'cookiePath' =&gt; $G_ROOT. '/cache/cookie', // cookie缓存文件路径
        'webTokenPath' =&gt; $G_ROOT. '/cache/webToken', // webToken缓存文件路径
);

[root@monitor alertscripts]# vim WeiXin-Private-API/test.php

&lt;?php
require "config.php";
require "include/WeiXin.php";

$weiXin = new WeiXin($G_CONFIG['weiXin']);

$testFakeId = "$argv[1]";
$msg = "$argv[3]";
 print_r($weiXin-&gt;send($testFakeId, "$msg"));</pre>
<span style="color: #ff00ff;">注意</span>：这里$msg="$argv[3]"表示zabbix传入的第三个参数，因为在zabbix报警时会传入三个参数：一是微信好友ID，二是报警信息的主题，三是报警信息的具体内容，这里跳过了报警信息主题，直接发送报警信息内容

#### 2.3 创建报警脚本

<pre class="lang:sh decode:true ">[root@monitor alertscripts]# vim weixin
/usr/local/php/bin/php /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/test.php "$1" "$2" "$3"</pre>

#### 2.4 修改权限

<pre class="lang:sh decode:true ">[root@monitor alertscripts]# chown www. weixin WeiXin-Private-API -R
[root@monitor alertscripts]# chmod +x weixin</pre>

#### 2.5 测试脚本

<pre class="lang:sh decode:true ">[root@monitor alertscripts]# ./weixin 353131080 "" "hello weixin"
PHP Notice:  curl_setopt(): CURLOPT_SSL_VERIFYHOST with value 1 is deprecated and will be removed as of libcurl 7.28.1\. It is recommended to use value 2 instead in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/include/LeaWeiXinClient.php on line 32

Notice: curl_setopt(): CURLOPT_SSL_VERIFYHOST with value 1 is deprecated and will be removed as of libcurl 7.28.1\. It is recommended to use value 2 instead in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/include/LeaWeiXinClient.php on line 32
PHP Notice:  Undefined index: HTTP_USER_AGENT in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/include/LeaWeiXinClient.php on line 33

Notice: Undefined index: HTTP_USER_AGENT in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/include/LeaWeiXinClient.php on line 33
PHP Notice:  curl_setopt(): CURLOPT_SSL_VERIFYHOST with value 1 is deprecated and will be removed as of libcurl 7.28.1\. It is recommended to use value 2 instead in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/include/LeaWeiXinClient.php on line 32

Notice: curl_setopt(): CURLOPT_SSL_VERIFYHOST with value 1 is deprecated and will be removed as of libcurl 7.28.1\. It is recommended to use value 2 instead in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/include/LeaWeiXinClient.php on line 32
PHP Notice:  Undefined index: HTTP_USER_AGENT in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/include/LeaWeiXinClient.php on line 33

Notice: Undefined index: HTTP_USER_AGENT in /usr/local/share/zabbix/alertscripts/WeiXin-Private-API/include/LeaWeiXinClient.php on line 33
stdClass Object
(
    [base_resp] =&gt; stdClass Object
        (
            [ret] =&gt; 0
            [err_msg] =&gt; ok
        )

)</pre>

#### 2.6 查看结果

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-11@2x.png)

</div>
<div></div>
<div>

### 3.配置zabbix

<div></div>

#### 3.1 创建媒体类型

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-0@2x.png)

#### 3.2 填写脚本名称

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-1@2x.png)

#### 3.3 编辑用户

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-2@2x.png)

#### 3.4 添加weixin脚本

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-3@2x.png)

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-4@2x.png)

#### 3.5 编辑动作

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-5@2x.png)

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-6@2x.png)

</div>

### 4.测试报警

<div>停掉mongoldb服务</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-13@2x.png)</div>
