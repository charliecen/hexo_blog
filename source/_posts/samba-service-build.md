---
title: samba服务搭建
tags:
  - samba
  - smbclient
id: 646
categories:
  - Linux
  - Samba
date: 2015-10-23 16:47:50
---

<div>好久没弄这个，今天朋友问我samba服务问题。又重新弄了一遍，加深下记忆。</div>
<div></div>
<div>系统：centos6.7</div>
<div></div>

### 1\. 安装
<!-- more -->
<pre class="lang:sh decode:true">[root@VM-241 ~]# yum install -y samba samba-client</pre>

### 2\. 修改配置文件

<pre class="lang:sh decode:true">[root@VM-241 ~]# vim /etc/samba/smb.conf
    [global]
    workgroup = MYGROUP
    server string = Samba Server Version %v
    #允许哪些网段访问共享服务
    hosts allow = 127\. 10.19.21\. 10.19.10.
    # logs split per machine
    log file = /var/log/samba/log.%m
    # max 50KB per log file, then rotate
    max log size = 50
    security = user
    passdb backend = tdbsam
    load printers = yes
    cups options = raw

    [homes]
    comment = Home Directories
    browseable = no
    writable = yes

    [printers]
    comment = All Printers
    path = /var/spool/samba
    browseable = no
    guest ok = no
    writable = no
    printable = yes

    [share] #共享名
    comment = Public Stuff #共享说明
    path = /home/share #共享路径
    public = no #不允许匿名登录
    writable = yes #可写
    printable = no #关闭打印服务
    write list = @user1 #可写用户组，多个可用空格分隔
    valid users = @user1 #有效的用户组，多个可用空格分隔
    browseable = yes #用户可浏览</pre>

### 3\. 测试配置文件语法

<pre class="lang:sh decode:true">[root@VM-241 ~]# testparm
Load smb config files from /etc/samba/smb.conf
Processing section "[homes]"
Processing section "[printers]"
Processing section "[share]"
Loaded services file OK.
Server role: ROLE_STANDALONE
Press enter to see a dump of your service definitions

[global]
    workgroup = MYGROUP
    server string = Samba Server Version %v
    log file = /var/log/samba/log.%m
    max log size = 50
    idmap config * : backend = tdb
    hosts allow = 127., 10.19.21., 10.19.10.
    cups options = raw

[homes]
    comment = Home Directories
    read only = No
    browseable = No

[printers]
    comment = All Printers
    path = /var/spool/samba
    printable = Yes
    print ok = Yes
    browseable = No

[share]
    comment = Public Stuff
    path = /home/share
    write list = @user1
    read only = No</pre>

### 4\. 创建系统用户和smb密码

<pre class="lang:sh decode:true">[root@VM-241 ~]# useradd  user1
[root@VM-241 ~]# smbpasswd -a user1
New SMB password:
Retype new SMB password:</pre>

### 5\. 创建共享目录

<pre class="lang:sh decode:true">[root@VM-241 ~]# mkdir /home/share
[root@VM-241 ~]# chmod 777 /home/share</pre>

### 6\. 现在本机测试

<pre class="lang:sh decode:true">[root@VM-241 ~]# smbclient //localhost/share -U user1
Enter user1's password:
Domain=[MYGROUP] OS=[Unix] Server=[Samba 3.6.23-20.el6]
smb: \&gt; put hello.py
putting file hello.py as \hello.py (22.4 kb/s) (average 22.4 kb/s)
smb: \&gt; ls
  .                                   D        0  Fri Oct 23 14:02:34 2015
  ..                                  D        0  Fri Oct 23 13:59:57 2015
  hello.py                            A      321  Fri Oct 23 14:02:34 2015

        35036 blocks of size 524288\. 20525 blocks available
smb: \&gt; exit</pre>

### 7\. 客户端连接

##### 7.1 测试客户端是mac，所以打开Finder, 菜单里找到”前往”—&gt;”连接服务器”、或者运行command+k命令

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151023-0@2x.png)

##### 7.2 输入用户名和密码

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151023-1@2x.png)

##### 7.3 查看刚上传的共享文件

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151023-2@2x.png)

##### 7.4 从客户端添加文件

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151023-3@2x.png)

##### 7.5 到服务器上查看

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151023-4@2x.png)

### 8.添加匿名用户访问

<pre class="lang:sh decode:true">[root@VM-241 ~]# vim /etc/samba/smb.conf
        [global]
        ...
        security = user
        passdb backend = tdbsam
        map to guest = bad user #允许匿名访问
        ...

        [public]
        comment = Public Stuff
        path = /home/public
        public = yes
        writable = yes
        printable = no
        guest ok = yes #允许匿名访问</pre>

### 9.创建共享目录和添加权限

<pre class="lang:sh decode:true">[root@VM-241 ~]# mkdir /home/public
[root@VM-241 ~]# chmod 777 /home/public</pre>

### 10.重启服务

<pre class="lang:sh decode:true">[root@VM-241 ~]# /etc/init.d/smb restart</pre>

### 11.服务器本地测试

<pre class="lang:sh decode:true ">[root@VM-241 ~]# smbclient //localhost/public
Enter guest's password:
Anonymous login successful
Domain=[MYGROUP] OS=[Unix] Server=[Samba 3.6.23-20.el6]
smb: \&gt; ls
  .                                   D        0  Fri Oct 23 15:16:05 2015
  ..                                  D        0  Fri Oct 23 15:16:05 2015

        35036 blocks of size 524288\. 20524 blocks available
            list.txt            .ssh/
smb: \&gt; put md5.txt
putting file md5.txt as \md5.txt (8.8 kb/s) (average 8.8 kb/s)
smb: \&gt; ls
  .                                   D        0  Fri Oct 23 15:17:00 2015
  ..                                  D        0  Fri Oct 23 15:16:05 2015
  md5.txt                             A      153  Fri Oct 23 15:17:00 2015

        35036 blocks of size 524288\. 20524 blocks available</pre>

### 12.客户端测试

##### 12.1 测试客户端是mac，所以打开Finder, 菜单里找到”前往”—&gt;”连接服务器”、或者运行command+k命令

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151023-5@2x.png)

##### 12.2 匿名访问，选择"客人"

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151026-0@2x.png)

##### 12.3 查看结果

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151023-9@2x.png)

* * *

&nbsp;

### 13\. samba参数详解

<pre class="lang:sh decode:true ">        [share] # 该共享的共享名
        comment = smb share test # 该共享的备注
        path = /home/share # 共享路径
        allow hosts = host(subnet) # 设置该Samba服务器允许的工作组或者域
        deny hosts = host(subnet) # 设置该Samba服务器拒绝的工作组或者域
        available = yes|no # 设置该共享目录是否可用
        browseable = yes|no # 设置该共享目录是否可显示
        writable = yes|no # 指定了这个目录缺省是否可写，也可以用readonly = no来设置可写
        public = yes|no # 指明该共享资源是否能给游客帐号访问，guest ok = yes其实和public = yes是一样的
        user = user, @group # user设置所有可能使用该共享资源的用户，也可以用@group代表group这个组的所有成员，不同的项目之间用空格或者逗号隔开
        valid users = user, @group # 指定能够使用该共享资源的用户和组
        invalid users = user, @group # 指定不能够使用该共享资源的用户和组
        read list = user, @group # 指定只能读取该共享资源的用户和组
        write list = user, @group # 指定能读取和写该共享资源的用户和组
        admin list = user, @group # 指定能管理该共享资源（包括读写和权限赋予等）的用户和组
        hide dot files = yes|no # 指明是否像UNIX那样隐藏以“.”号开头的文件
        create mode = 0755 # 指明新建立的文件的属性，一般是0755
        directory mode = 0755 # 指明新建立的目录的属性，一般是0755
        sync always = yes|no # 指明对该共享资源进行写操作后是否进行同步操作
        short preserve case = yes|no # 指明是否区分文件名大小写
        preserve case = yes|no # 指明是否保持大小写
        case sensitive = yes|no # 指明是否对大小写敏感，一般选no，不然可能引起错误
        mangle case = yes|no # 指明混合大小写
        default case = upper|lower # 指明缺省的文件名是全部大写还是小写
        force user = testuser # 强制把建立文件的属主是谁。如果我有一个目录，让guest可以写，那么guest就可以删除，如果我用force user= testuser强制建立文件的属主是testuser，同时限制create mask = 0755，这样guest就不能删除了
        wide links = yes|no # 指明是否允许共享外符号连接，比如共享资源里面有个连接指向非共享资源里面的文件或者目录，如果设置wide links = no将使该连接不可用
        max connections = 100 # 设定最大同时连接数
        delete readonly = yes|no # 指明能否删除共享资源里面已经被定义为只读的文件</pre>
&nbsp;
