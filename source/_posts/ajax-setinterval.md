---
title: Ajax+setInterval实时更新
tags:
  - ajax
  - setInterval
id: 816
categories:
  - Dev
  - PHP
date: 2016-09-20 15:07:31
---

<div>要求页面部分数据更新，具有实时性。需要用到定时器(setInter)和异步技术(Ajax)</div>
<div>首先前段页面</div>
<!-- more -->
<div>
<pre class="lang:php decode:true ">index.php
&lt;div class="count" id="count" &gt;100&lt;/div&gt;
&lt;script src="/js/jquery-2.1.1.min.js"&gt;&lt;/script&gt;
&lt;script type="text/javascript"&gt;
    setInterval(function(){
        $.ajax({
            type:"post",
            dataType:"json",
            url: 'index.php?r=test/getdata',
            success:function(data){
                $("#count").html(data[0]['id']);
                //console.log(data[0]['id']);
            },
            error: function(){
                alert('wrong');
            },
        });
    },3000);

&lt;/script&gt;</pre>
后端处理页面，可以从数据库获取数据也可以中接口，这里自定义数组
<pre class="lang:php decode:true ">public function actionGetdata()
    {
        $data = array(
            array('id'=&gt;4,'name'=&gt;’test1'
        );
        echo json_encode($data);

    }

    public function actionIndex(){
        return $this-&gt;render('index');
    }</pre>
<div>浏览器访问</div>
<div>[http://test-advanced.com/index.php?r=test/index](http://test-advanced.com/index.php?r=test/index)   #test表示控制器，index表示方法</div>
<div>更改数组里的id，前段页面数据实时变化</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2016/09/QQ20160920-0.png)</div>
</div>
