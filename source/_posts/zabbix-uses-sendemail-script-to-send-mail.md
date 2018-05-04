---
title: zabbix使用sendEmail脚本发送邮件
tags:
  - sendEmail
  - zabbix
id: 69
categories:
  - Scripts
  - Zabbix
date: 2015-09-09 12:01:55
---

zabbix版本：2.5.0

今天上午来上班，打开邮箱没有备份通知邮件，难道是被拒了。马上登陆服务器查看，果然是。
<pre class="lang:sh decode:true"># less /var/mail/root
reason: 550 Ip frequency limited. http://service.mail.qq.com/cgi-bin/help?subtype=1&amp;&amp;id=20022&amp;&amp;no=1000725</pre>
&nbsp;
<!-- more -->
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150909-1@2x.jpg)</div>
<div>下面我将选择sendEmail来作为邮件客户端，sendEmail是一个轻量级的，命令行的SMTP邮件客户端</div>
<div></div>
<div>下载地址：</div>
<div>
<pre class="lang:sh decode:true"># wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz</pre>
解压：
<pre class="lang:sh decode:true"># tar xf sendEmail-v1.56.tar.gz</pre>
<div>

拷贝命令
<pre class="lang:sh decode:true"># cp sendEmail-v1.56/sendEmail /usr/local/bin/
# chmod +x /usr/local/bin/sendEmail</pre>
编写邮件脚本
<pre class="lang:sh decode:true"># vim sendEmail.sh
#!/bin/bash
to_mail=$1
subject=$2
body=$3
from_mail="admin@example.com"
smtp="smtp.exmail.qq.com"
passwd="admin"

/usr/local/bin/sendEmail  -f $from_mail -t $to_mail -s $smtp -u "$subject" -m "$body"  -xu $from_mail -xp $passwd -o message-content-type=text -o message-charset=utf8 -o tls=auto &gt;&gt; /var/log/zabbix/sendEmail.log</pre>
<pre class="lang:sh decode:true">命令说明：
/usr/local/bin/sendEmail      命令主程序
-f admin@example.com          发件人邮箱
-s smtp.exmail.qq.com         发件人邮箱的smtp服务器
-u “邮件测试标题"               邮件的标题
-o message-content-type=text  邮件内容的格式,text表示它是text格式
-o message-charset=utf8       邮件内容编码
-o tls=auto                   加密类型自动
-xu admin@example.com         发件人邮箱的用户名
-xp admin                     发件人邮箱密码
-m "邮件测试内容"               邮件的具体内容
如果有不明白的可以查看帮助信息
sendEmail -h</pre>
测试邮件发送
<pre class="lang:sh decode:true "># chmod +x sendEmail.sh
# ./sendEmail.sh monitor@baicare.com “邮件测试标题” “邮件测试内容”</pre>
&nbsp;

</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150909-2@2x.jpg)</div>
<div>下面把此脚本应用到zabbix里</div>
<div>  ![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150909-3@2x.jpg)</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150909-4@2x.jpg)</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150909-5@2x.jpg)</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150909-6@2x.jpg)</div>
<div>到服务器里停止svn服务，测试是否收到邮件</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150909-7@2x.jpg)</div>
</div>
