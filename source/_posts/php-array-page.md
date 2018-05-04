---
title: PHP数组分页
tags:
  - php
  - php_array
  - show_array
id: 764
categories:
  - PHP
date: 2016-09-12 13:52:29
---

<div>由于从api获取的数据无法通过框架分页类来分页，所以需要自己写分页方法</div>
<div>代码如下</div>
<!-- more -->
<div>
<pre class="lang:php decode:true ">&lt;?php

//数组数据
$data = array(
    array('id'=&gt;1,'name'=&gt;'test1'),
    array('id'=&gt;2,'name'=&gt;'test2'),
    array('id'=&gt;3,'name'=&gt;'test3'),
    array('id'=&gt;4,'name'=&gt;'test4'),
    array('id'=&gt;5,'name'=&gt;'test5'),
    array('id'=&gt;6,'name'=&gt;'test6'),
    array('id'=&gt;7,'name'=&gt;'test7'),
);

//获取当前页
$page = intval(isset($_GET['page'])) ? intval($_GET['page']) : 1;
//排序order 0 - 不变     1- 反序 
$order = 0;
//每页显示数
$count = 3;

$d = page_array($count,$page,$data,$order);
echo '&lt;pre&gt;' ;
print_r($d);
//url地址
$url = 'http://127.0.0.1:81/test.php';
echo show_array($countpage,$url);

/** 
 * 数组分页函数  核心函数  array_slice 
 * 用此函数之前要先将数据库里面的所有数据按一定的顺序查询出来存入数组中 
 * $count   每页多少条数据 
 * $page   当前第几页 
 * $array   查询出来的所有数组 
 * order 0 - 不变     1- 反序 
 */   

function page_array($count,$page,$array,$order){  
    global $countpage; #定全局变量  
    $page=(empty($page))?'1':$page; #判断当前页面是否为空 如果为空就表示为第一页面   
       $start=($page-1)*$count; #计算每次分页的开始位置  
    if($order==1){  
      $array=array_reverse($array);  
    }     
    $totals=count($array);    
    $countpage=ceil($totals/$count); #计算总页面数  
    $pagedata=array();  
    $pagedata=array_slice($array,$start,$count);  
    return $pagedata;  #返回查询数据  
}  
/** 
 * 分页及显示函数 
 * $countpage 全局变量，照写 
 * $url 当前url 
 */  
function show_array($countpage,$url){  
     $page=empty($_GET['page'])?1:$_GET['page'];  
     if($page &gt; 1){  
        $uppage=$page-1;  

     }else{  
        $uppage=1;  
     }  

     if($page &lt; $countpage){  
        $nextpage=$page+1;  

     }else{  
            $nextpage=$countpage;  
     }  

    $str='&lt;div style="border:1px; width:300px; height:30px; color:#9999CC"&gt;';  
    $str.="&lt;span&gt;共  {$countpage}  页 / 第 {$page} 页&lt;/span&gt;&amp;nbsp;";  
    $str.="&lt;span&gt;&lt;a href='$url?page=1'&gt;   首页  &lt;/a&gt;&lt;/span&gt;&amp;nbsp;";  
    $str.="&lt;span&gt;&lt;a href='$url?page={$uppage}'&gt; 上一页  &lt;/a&gt;&lt;/span&gt;&amp;nbsp;";  
    $str.="&lt;span&gt;&lt;a href='$url?page={$nextpage}'&gt;下一页  &lt;/a&gt;&lt;/span&gt;&amp;nbsp;";  
    $str.="&lt;span&gt;&lt;a href='$url?page={$countpage}'&gt;尾页  &lt;/a&gt;&lt;/span&gt;&amp;nbsp;";  
    $str.='&lt;/div&gt;';  
    return $str;  
}  
?&gt;</pre>
结果如下：

![](http://blog.cenhq.com/wp-content/uploads/2016/09/QQ20160912-0.png)

</div>
