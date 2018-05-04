---
title: thinkphp页面显示权限控制
tags:
  - mongo or查询
  - _complex
  - _logic=&gt;"or"
  - 报表浏览权限
  - 权限控制
id: 846
categories:
  - PHP
date: 2016-12-08 19:10:05
---

需求：报表生成后，需要发布报表浏览页，在发布的同时，需要设置权限；创建者有浏览该报表权限，所属部门有浏览权限，员工级别有浏览权限，只要包含其中就可；

如图所示：

![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161208-0.png)
<!-- more -->
用户信息在session里保存，所以当创建报表是，获取用户信息，当发布报表时，写入用户信息和用户设置的权限到mongo库里

下面是显示的操作方法
<pre class="lang:php decode:true ">//获取用户名,只显示当前用户的报表
$info = $_SESSION['info']['data'];
$map['user'] = $info['user_name'];
$map = $this-&gt;getAuthInfo($map);
$where['_complex'] = array('_logic'=&gt;"or", array('user'=&gt;$map['user']), array('dept'=&gt;$map['dept']),array('level'=&gt;$map['level']));
$data = $model-&gt;order('ym desc')-&gt;where($where)-&gt;limit($Page-&gt;firstRow.','.$Page-&gt;listRows)-&gt;select();</pre>
<pre class="lang:php decode:true ">private function getAuthInfo($map)
    //获取当前用户的部门和级别
        $info = $_SESSION['title'];
        //判断用户所属部门
        if($info['department'] == '技术服务部')
            $map['dept'] = 'jw';
        elseif ($info['department'] == '手游服务部')
            $map['dept'] = 'sy';
        elseif ($info['department'] == '端游服务部')
            $map['dept'] = 'dy';
        elseif ($info['department'] == '监控服务部')
            $map['dept'] = 'jk';
        else
            $map['dept'] = 'all';

        //判断用户的级别
        if($info['powerTitle'] == '员工')
            $map['level'] = 'staff';
        elseif ($info['powerTitle'] == '组长')
            $map['level'] = 'leader';
        elseif ($info['powerTitle'] == '主管')
            $map['level'] = 'competent';
        elseif ($info['powerTitle'] == '经理')
            $map['level'] = 'manager';
        elseif ($info['powerTitle'] == '总监')
            $map['level'] = 'director';

        return $map;
    }</pre>
显示效果如下：

![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161208-1.png)
