---
title: zabbix-api使用php版本
tags:
  - zabbix-api
id: 768
categories:
  - PHP
  - Zabbix
date: 2016-09-12 14:28:24
---

### API简介

Zabbix API开始扮演着越来越重要的角色，尤其是在集成第三方软件和自动化日常任务时。很难想象管理数千台服务器而没有自动化是多么的困难。Zabbix API为批量操作、第三方软件集成以及其他作用提供可编程接口。

Zabbix API是在1.8版本中开始引进并且已经被广泛应用。所有的Zabbix移动客户端都是基于API，甚至原生的WEB前端部分也是建立在它之上。Zabbix API 中间件使得架构更加模块化也避免直接对数据库进行操作。它允许你通过JSON RPC协议来创建、更新和获取Zabbix对象并且做任何你喜欢的操作【当然前提是你拥有认证账户】。
Zabbix API提供两项主要功能：
<!-- more -->
*   远程管理Zabbix配置
*   远程检索配置和历史数据

#### **使用JSON**

API 采用JSON-RPC实现。这意味着调用任何函数，都需要发送POST请求，输入输出数据都是以JSON格式。大致工作流如下：

*   准备JSON对象，它描述了你想要做什么（创建主机，获取图像，更新监控项等）。
*   采用POST方法向[http://example.com/zabbix/api_jsonrpc.php发送此JSON对象](http://example.com/zabbix/api_jsonrpc.php%E5%8F%91%E9%80%81%E6%AD%A4JSON%E5%AF%B9%E8%B1%A1). [http://example.com/zabbix/是Zabbix前端地址。api_jsonrpc.php是调用API的PHP脚本。可在安装可视化前端的目录下找到。](http://example.com/zabbix/%E6%98%AFZabbix%E5%89%8D%E7%AB%AF%E5%9C%B0%E5%9D%80%E3%80%82api_jsonrpc.php%E6%98%AF%E8%B0%83%E7%94%A8API%E7%9A%84PHP%E8%84%9A%E6%9C%AC%E3%80%82%E5%8F%AF%E5%9C%A8%E5%AE%89%E8%A3%85%E5%8F%AF%E8%A7%86%E5%8C%96%E5%89%8D%E7%AB%AF%E7%9A%84%E7%9B%AE%E5%BD%95%E4%B8%8B%E6%89%BE%E5%88%B0%E3%80%82)
*   获取JSON格式响应。
*   注：请求除了必须是POST方法之外，HTTP Header Content-Type必须为【application/jsonrequest，application/json-rpc，application/json】其中之一。
可以采用脚本或者任何"手动"支持JSON RPC的工具来使用API。而首先需要了解的就是如何验证和如何使用验证ID来获取想要的信息。

</div>
<div>

#### **基本请求格式**

<div>
<div>Zabbix API 简化的JSON请求如下：</div>
<div>
<pre class="lang:sh decode:true ">{
"jsonrpc": "2.0",
"method": "method.name",
"params": {
"param_1_name": "param_1_value",
"param_2_name": "param_2_value"
},
"id": 1,
"auth": "159121b60d19a9b4b55d49e30cf12b81",
}</pre>
下面一行一行来看：

*   "jsonrpc": "2.0"-这是标准的JSON RPC参数以标示协议版本。所有的请求都会保持不变。
*   "method": "method.name"-这个参数定义了真实执行的操作。例如：host.create、item.update等等
*   "params"-这里通过传递JSON对象来作为特定方法的参数。如果你希望创建监控项，"name"和"key_"参数是需要的，每个方法需要的参数在Zabbix API文档中都有描述。
*   "id": 1-这个字段用于绑定JSON请求和响应。响应会跟请求有相同的"id"。在一次性发送多个请求时很有用，这些也不需要唯一或者连续
*   "auth": "159121b60d19a9b4b55d49e30cf12b81"-这是一个认证令牌【authentication token】用以鉴别用户、访问API。这也是使用API进行相关操作的前提-获取认证ID。

### API 使用

*   **环境准备**
Zabbix API是基于JSON-RPC 2.0规格，具体实现可以选择任何你喜欢的编程语言或者手动方式。这里我们采用的Python和基于Curl的方式来做示例。Python 2.7版本已经支持JSON，所以不再需要其他模块组件。当然可以采用Perl、Ruby、PHP之类的语言，使用前先确保相应JSON模块的安装。

*   **身份验证**
<div>
<div>任何Zabbix API客户端在真正工作之前都需要验证它自身。在这里是采用User.login方法。这个方法接受一个用户名和密码作为参数并返回验证ID，一个安全哈希串用于持续的API调用（在使用User.logout之前该验证ID均有效）。这里使用php代码获取</div>
<div>
<pre class="lang:php decode:true ">function Curl($url,$header,$info){
        $ch = curl_init();
        curl_setopt($ch,CURLOPT_URL, $url);
        curl_setopt($ch,CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch,CURLOPT_HTTPHEADER,$header);
        curl_setopt($ch,CURLOPT_POST, 1);
        curl_setopt($ch,CURLOPT_POSTFIELDS, $info);
        $response = curl_exec($ch);
        curl_close($ch);
        return json_decode($response);
    }</pre>
<pre class="lang:php decode:true">//获取token
function GetToken() {

        $logininfo = [
            'jsonrpc' =&gt; '2.0',
            'method' =&gt; 'user.login',
            'params' =&gt; [
                'user' =&gt; ‘username',
                'password' =&gt; ‘password',
            ],
            'id' =&gt; 1,
        ];

        $url = ‘http://www.example.com/api_jsonrpc.php';
        $data = json_encode($logininfo);
        $header = ["Content-type: application/json"];
        //实例化模型
        $model = new GetZabbixToken();
        if (!$result = $model-&gt;Curl($url, $header, $data)) {
            echo ‘无法获取token';
            exit;
        }

        $token = $result-&gt;result;
        return $token;
    }

//获取主机信息
function GetHosts() {
        $hostinfo = [
            'jsonrpc' =&gt; '2.0',
            'method' =&gt; 'host.get',
            'params' =&gt; [
                'output' =&gt; ['hostid', 'name'],
                'filter' =&gt; ['host' =&gt; ''],
            ],
            'auth' =&gt; GetToken(),
            'id' =&gt; 1
        ];
        $url = ‘http://www.example.com/api_jsonrpc.php';
        $data = json_encode($hostinfo);
        $header = ["Content-type: application/json"];
        if (!$result = Curl($url, $header, $data)) {
            echo '无法获取主机信息';
            exit;
        }
        return $result-&gt;result;
    }</pre>
这里我用前端页面渲染，效果如下

![](http://blog.cenhq.com/wp-content/uploads/2016/09/hostinfo.jpg)

查看详情页是具体主机硬件信息

![](http://blog.cenhq.com/wp-content/uploads/2016/09/info.jpg)

</div>
代码如下：
<pre class="lang:php decode:true ">function GetInfo($hostid){
        $info = [
            'jsonrpc' =&gt; '2.0',
            'method' =&gt; 'item.get',
            'params' =&gt; [
                'output'    =&gt;  ['key_','lastvalue','hostid'],
                'filter'    =&gt;  [
                    'hostid' =&gt;  $hostid,
                    'key_'    =&gt;  [
                        'vfs.fs.size[/,total]',
                        'vfs.fs.size[/,used]',
                        'vfs.fs.size[/,free]',
                        'vfs.fs.size[/data,total]',
                        'vfs.fs.size[/data,used]',
                        'vfs.fs.size[/data,free]',
                        'system.cpu.load[percpu,avg15]',
                        'system.cpu.load[percpu,avg5]',
                        'system.cpu.load[percpu,avg1]',
                        'system.cpu.util[,idle]',
                        'system.cpu.switches',
                        'system.cpu.util[,interrupt]',
                        'system.cpu.util[,iowait]',
                        'vm.memory.size[available]',
                        'vm.memory.size[total]',
                        'custom.vfs.dev.read.ms[sda]',
                        'custom.vfs.dev.write.ms[sda]',
                        'icmpping',
                        'icmppingsec',
                        'icmppingloss',
                        'iptables.lines',
                        'kernel.maxfiles',
                        'net.if.in[em1]',
                        'net.if.in[em2]',
                        'net.if.in[em3]',
                        'net.if.in[em4]',
                        'net.if.out[em1]',
                        'net.if.out[em2]',
                        'net.if.out[em3]',
                        'net.if.out[em4]',
                        'proc.num[]',
                        'system.boottime',
                        'system.localtime',
                        'system.swap.size[,free]',
                        'system.swap.size[,pfree]',
                        'system.swap.size[,total]',
                        'system.uname',
                        'system.uptime',
                        'system.users.num',
                        'vfs.fs.inode[/,pfree]',
                        'vfs.fs.inode[/data,pfree]',
                    ],
                ],
            ],
            'auth'  =&gt;  GetToken(),
            'id'    =&gt;  1,
        ];

        $url = ‘http://www.example.com/api_jsonrpc.php';
        $info =  json_encode($info);
        $header = ["Content-type: application/json"];
        if(!$info = $model-&gt;Curl($url,$header,$info)){
            echo '无法获取信息';
            exit;
        }
        return $info-&gt;result;
    }</pre>
&nbsp;

</div>
</div>
</div>
</div>
</div>
