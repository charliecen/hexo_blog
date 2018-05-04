---
title: php多维数组整理
tags:
  - highcharts
  - php
id: 828
categories:
  - Dev
  - PHP
date: 2016-11-29 16:15:08
---

获取的数据需要到highcharts中显示，所以格式如下，但是在显示的时候，会有时间不存在，导致在一起显示的无法正常显示。所以需要整理数组是同样长度，并且在无时间的值为0；
<!-- more -->
<pre class="lang:php decode:true ">array (size=3)
  0 =&gt; 
    array (size=2)
      'day' =&gt; 
        array (size=16)
          0 =&gt; string '16-09-02' (length=8)
          1 =&gt; string '16-09-03' (length=8)
          2 =&gt; string '16-09-04' (length=8)
          3 =&gt; string '16-09-05' (length=8)
          4 =&gt; string '16-09-06' (length=8)
          5 =&gt; string '16-09-07' (length=8)
          6 =&gt; string '16-09-08' (length=8)
          7 =&gt; string '16-09-09' (length=8)
          8 =&gt; string '16-09-10' (length=8)
          9 =&gt; string '16-09-11' (length=8)
          10 =&gt; string '16-09-12' (length=8)
          11 =&gt; string '16-09-13' (length=8)
          12 =&gt; string '16-09-14' (length=8)
          13 =&gt; string '16-09-15' (length=8)
          14 =&gt; string '16-09-16' (length=8)
          15 =&gt; string '16-09-17' (length=8)
      '板块回复帖总数' =&gt; 
        array (size=16)
          0 =&gt; int 98
          1 =&gt; int 207
          2 =&gt; int 188
          3 =&gt; int 125
          4 =&gt; int 196
          5 =&gt; int 153
          6 =&gt; int 228
          7 =&gt; int 289
          8 =&gt; int 254
          9 =&gt; int 245
          10 =&gt; int 220
          11 =&gt; int 326
          12 =&gt; int 286
          13 =&gt; int 497
          14 =&gt; int 419
          15 =&gt; int 243
  1 =&gt; 
    array (size=2)
      'day' =&gt; 
        array (size=13)
          0 =&gt; string '16-09-03' (length=8)
          1 =&gt; string '16-09-05' (length=8)
          2 =&gt; string '16-09-06' (length=8)
          3 =&gt; string '16-09-07' (length=8)
          4 =&gt; string '16-09-08' (length=8)
          5 =&gt; string '16-09-09' (length=8)
          6 =&gt; string '16-09-11' (length=8)
          7 =&gt; string '16-09-12' (length=8)
          8 =&gt; string '16-09-13' (length=8)
          9 =&gt; string '16-09-14' (length=8)
          10 =&gt; string '16-09-15' (length=8)
          11 =&gt; string '16-09-16' (length=8)
          12 =&gt; string '16-09-17' (length=8)
      '版主回复帖数' =&gt; 
        array (size=13)
          0 =&gt; int 1
          1 =&gt; int 4
          2 =&gt; int 2
          3 =&gt; int 3
          4 =&gt; int 3
          5 =&gt; int 2
          6 =&gt; int 1
          7 =&gt; int 4
          8 =&gt; int 8
          9 =&gt; int 5
          10 =&gt; int 2
          11 =&gt; int 3
          12 =&gt; int 1
  2 =&gt; 
    array (size=2)
      'day' =&gt; 
        array (size=16)
          0 =&gt; string '16-09-02' (length=8)
          1 =&gt; string '16-09-03' (length=8)
          2 =&gt; string '16-09-04' (length=8)
          3 =&gt; string '16-09-05' (length=8)
          4 =&gt; string '16-09-06' (length=8)
          5 =&gt; string '16-09-07' (length=8)
          6 =&gt; string '16-09-08' (length=8)
          7 =&gt; string '16-09-09' (length=8)
          8 =&gt; string '16-09-10' (length=8)
          9 =&gt; string '16-09-11' (length=8)
          10 =&gt; string '16-09-12' (length=8)
          11 =&gt; string '16-09-13' (length=8)
          12 =&gt; string '16-09-14' (length=8)
          13 =&gt; string '16-09-15' (length=8)
          14 =&gt; string '16-09-16' (length=8)
          15 =&gt; string '16-09-17' (length=8)
      '板块主题帖总数' =&gt; 
        array (size=16)
          0 =&gt; int 10
          1 =&gt; int 39
          2 =&gt; int 56
          3 =&gt; int 21
          4 =&gt; int 31
          5 =&gt; int 27
          6 =&gt; int 42
          7 =&gt; int 59
          8 =&gt; int 46
          9 =&gt; int 33
          10 =&gt; int 45
          11 =&gt; int 47
          12 =&gt; int 64
          13 =&gt; int 76
          14 =&gt; int 67
          15 =&gt; int 36</pre>
这里写个私有方法，方便内部调用
<pre class="lang:php decode:true ">private function getDateLength($arr)
    {
        //数组映射
        $new_arr = [];
        foreach($arr as $k=&gt;$v){
            foreach($v as $k1=&gt;$v1){
                if($k1 != 'day'){
                    foreach($v['day'] as $k2=&gt;$v2){
                        $new_arr[$k][$v2] = $v1[$k2];
                    }
                }
            }
        }
        //数组补值
        $data = [];
        $max = max($new_arr);
        foreach($new_arr as $k=&gt;$v){
            foreach($max as $k1=&gt;$v1){
                if(in_array($k1,array_keys($v))){
                    $data[$k][$k1] = $v[$k1];
                }else{
                    $data[$k][$k1] = 0;
                }
            }
        }
        //转化成原型
        $array = [];
        foreach($arr as $k=&gt;$v){
            foreach($v as $k1=&gt;$v1){
                if($k1 != 'day'){
                    $array[$k][$k1] = array_values($data[$k]);
                }else{
                    $array[$k][$k1] = array_keys($data[$k]);
                }
            }
        }
        return $array;
    }</pre>
显示效果如下：[
](http://blog.cenhq.com/wp-content/uploads/2016/11/2A8ADEDB-B2D0-483A-B014-09283F8B760A.jpg)

![](http://blog.cenhq.com/wp-content/uploads/2016/11/2A8ADEDB-B2D0-483A-B014-09283F8B760A.jpg)

&nbsp;
