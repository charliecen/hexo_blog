---
title: ssh隧道翻墙
tags:
  - socks
  - switchyOmega
  - tunnel
id: 728
categories:
  - Linux
date: 2015-12-18 13:21:32
---

<div>最近公司的网络到国外vps的路由丢包严重，国外vps上的shadowsocks无法使用</div>
<div>我就从公司阿里云服务器上面测试下到国外的vps路由是否正常，经测试可以访问。</div>
<div>然后我就想用阿里云做通道，公司到国外vps之间到通道。</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151218-1@2x.png)</div>
<div>实现步骤：</div>
<!-- more -->
### 1.云主机启用通道

<pre class="lang:sh decode:true ">[root@monitor ~]# ssh -qTNf -D 0.0.0.0:12345 root@xo.xo.xo.xo
root@xo.xo.xo.xo's password:</pre>
查看监控端口
<pre class="lang:sh decode:true ">[root@monitor ~]# netstat -lutnp |grep 12345
tcp        0      0 0.0.0.0:12345               0.0.0.0:*                   LISTEN      19633/ssh</pre>
添加防火墙策略
<pre class="lang:sh decode:true">[root@monitor ~]# vim /etc/sysconfig/iptables
-A INPUT -s xx.xx.xx.xx -p tcp  --dport 12345 -j ACCEPT
[root@monitor ~]# iptables -nL |grep 12345
ACCEPT     tcp  --  xx.xx.xx.xx        0.0.0.0/0           tcp dpt:12345</pre>
<div>注：xo.xo.xo.xo为vps地址，xx.xx.xx.xx为云主机地址</div>
<div></div>
<div>参数详解：</div>
<div>
<div>
<div>-q表示该命令进入安静模式</div>
</div>
</div>
<div>
<div>
<div>-T是指该命令不占用sh</div>
</div>
</div>
<div>
<div>
<div>-N是指该命令不执行远程命令</div>
</div>
</div>
<div>
<div>
<div>-f是指该命令在后台运行</div>
</div>
</div>
<div>
<div>
<div>-D是该命令重要参数，他的后面跟着socks5服务器的地址与端口</div>
</div>
</div>
<div>
<div>
<div>最后就是远程服务器用户名和地址</div>
<div></div>
</div>
</div>
<div>
<div>也可以使用端口映射</div>
<div>ssh -N -f -L 127.0.0.1:12345:10.21.0.34:22 test@12.3..4.5</div>
<div>其中-N，-f作用上面已经讲了，这里最重要的是-L命令，它作用是做本地映射，使得远程服务器的端口相当于本地某自定义的端口，如上面的命令，本地的12345端口就相当于10.21.0.34的22端口，以后我只需要使用ssh user@127.0.0.1 -p 12345命令就能登录10.21.0.34了，注意user是10.21.0.34的用户，最后就是我们所使用的中间服务器，这个地址需要是我们直接访问到的。其实上面所说的A主机就是127.0.0.1，B主机就是12.3.4.5，C主机就是10.21.0.34。当然了，有本地映射肯定有远程映射，就是把-L换成-R，这样我们访问远程主机的端口就相当于访问本地的端口，但我没发现该功能的更多用途。</div>
<div></div>
<div>
<div>
<div>如果你没有什么中间服务器，只是想做个端口映射，那也很简单，如下：</div>
</div>
</div>
<div>
<div>
<div>ssh -N -f -L 12345:12.3.4.5:22 test@12.3.4.5</div>
</div>
</div>
<div></div>

### 2.本地Chrome浏览器设置

首先需要插件SwitchyOmega，可以chrome---&gt;更多工具---&gt;扩展程序---&gt;更多扩展程序里获取

也可以直接点击：[https://chrome.google.com/webstore/category/extensions?hl=zh-CN](https://chrome.google.com/webstore/category/extensions?hl=zh-CN)

添加完成后，选项里设置新建情景模式

![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151218-3@2x.png)

![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151218-4@2x.png)

![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151218-5@2x.png)![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151218-6@2x.png)![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151218-7@2x.png)

</div>
测试下效果

![](http://blog.cenhq.com/wp-content/uploads/2015/12/QQ20151218-8@2x.png)
