---
title: ajax作用域范围无法获取返回值
tags:
  - ajax作用域
  - ajax同步
  - ajax异步
  - ajax返回值
id: 851
categories:
  - JavaScript
  - PHP
date: 2016-12-16 16:15:46
---

需求：判断title的值是否在mongo库里存在，如果不存在就继续，存在则返回false。
<!-- more -->
代码如下：
<pre class="lang:js decode:true">//检测标题是否存在
            var result = true;
            $.ajax({
                type: 'POST',
                url: '__APP__/Home/Custorm/chkTitle',
                data: {'title':$('#title').val()},
                success: function(data){
                    if(data.count &gt;= 1){
                        alert('标题已存在,请重新输入!');
                        $('#title').select();
                        result =  false;
                    }
                },
                error: function(e){
                    console.log(e);
                }
            });
            return result;</pre>
上述代码是有问题的，返回的result一直true；

后查到原因，是因为ajax默认是异步传输，也就是说，ajax并没有等待 success:function(data) 回调函数执行完，就已经向下执行了。于是 result的值永远只会等于其初始化的值，也就是true.

解决办法， 设置为同步传输。

//默认 async: true

//同步 async: false

参考：http://blog.csdn.net/zxstone/article/details/7297284
