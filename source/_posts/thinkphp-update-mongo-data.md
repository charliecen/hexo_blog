---
title: thinkphp修改mongo数据
tags:
  - mongo
  - update_mongo
id: 833
categories:
  - Dev
  - JavaScript
  - PHP
date: 2016-11-29 16:34:56
---

由于需要修改mongo库的`status`的值，首先要找到这条记录的id；

我这里的id在mysql库里有记录，每条记录里有`key_time`字段，所以需要获取这个字段的值；

获取该字段的值需要从url里获取，通过ajax方式传递到后台来处理；
<!-- more -->
<pre class="lang:js decode:true ">function commit(){
        var url = self.location.href;
        var title = $('h2').html().split('_');
        $.ajax({
            type: 'POST',
            url: '&lt;?php echo U("ReportBrowse/info")?&gt;',
            data : {url:url,title:title[0]},
            success: function (data) {
//                console.log(data);
            },
            error: function (e) {

            }
        });
}</pre>
后台会处理url，截取`key_time`的值
<pre class="lang:php decode:true">public function info()
{
        //截取url字符串
        $url = $_REQUEST['url'];
        if ($url) {
            $action = explode('&amp;',$url);
            $params = array();
            foreach ($action as $param) {
                $item = explode('=', $param);
                $params[$item[0]] = $item[1];
            }

            //根据预览页面的url中的key参数,从数据库yulan数据库中获取mongoId,然后到mongo库的template表中查找,修改status状态
            $this-&gt;editMongoId($params[$item[0]]);
}</pre>
这里调用了另外一个方法，这个方法就是查找mongoid, 然后根据mongoid修改`status`的值
<pre class="lang:php decode:true ">private function editMongoId($key_time)
{
        //实例化mysql库的yulan表,根据传递的key_time查找mongoid
        $yulan_mysql = new Model('yulan','','DB_MYSQL_KW');
        //实例化mongo库的template表,根据mongoid查找status状态
        $temp_mongo = new MongoModel('template','','DB_MONGO');
        if($key_time){
            //获取预览数据里的mongoid
            $where['key_time'] = array('eq',$key_time);
            $yulan_data = $yulan_mysql-&gt;field('mongoId')-&gt;where($where)-&gt;select();
            if($mid = $yulan_data[0]['mongoid']){
                //根据mongoid获取模板mongo里的所有数据
                $status = $temp_mongo-&gt;where(array(
                    '_id'   =&gt;  $mid,
                ))-&gt;select();
                //如果状态为"草稿",则修改mongo库的template的状态
                if($status[$mid]['status'] == '草稿'){
                    $data['status'] = '已发布';
                    $temp_mongo-&gt;where(array(
                        '_id'   =&gt;  $mid,
                    ))-&gt;save($data);
                }
            }
        }
}</pre>
&nbsp;
