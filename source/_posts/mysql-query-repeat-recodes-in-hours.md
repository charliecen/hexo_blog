---
title: mysql查询24小时内无重复的记录
tags:
  - 24小时内重复记录
  - mysql查询重复记录
id: 855
categories:
  - Dev
  - PHP
date: 2016-12-29 11:21:55
---

需求：
一次性解决问题率 = 一次解决的对话量/接入量
一次解决的对话量：客户在接入人工客服对话结束后24小时（暂定）内未再次请求人工服务的对话

由于条件还要加上日期间隔，所以从mysql查询结果到PHP处理。

<!-- more -->
例如：每隔2天内，用户请求对话结束时间到下次发起时间的间隔超过24小时，即为一次性解决对话量。然后再除以接入量，就是一次性解决问题率。

首先给出sql语句，间隔查询参考[mysql日期间隔查询](http://blog.cenhq.com/2016/12/06/mysql-select-date-interval-custom-date/)
<pre class="lang:mysql decode:true ">-- 间隔两天的记录
select 
  floor( (2 - to_days(FROM_UNIXTIME(1470022740)) % 2 + to_days(FROM_UNIXTIME(createTime)) )/2 ) as sortId ,
  createUserId,
  createTime,
  endTime 
FROM `think_kf_chat_im_group` 
  WHERE `endTime` &lt;&gt; 0 
  AND `createTime` BETWEEN 1470022740 AND 1470886740  
  and kfUserId &lt;&gt; 0 
order BY sortId,createUserId;</pre>
结果如下

![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161228-0.png)

下面把这些记录到php通过数组来处理
<pre class="lang:php decode:true">/**
     * 一次性问题解决率,用户对话结束后,24小时内不在有新的对话出现
     * @param $array array
     * return array
     */
    private function oneTimesQuesRate($array){
        $len = count($array);
        $arr = [];
        $sortId = [];
        $sortArr = [];
        $id = [];
        $count = [];
        $total = [];

        //遍历获取同一个sortId
        foreach($array as $v){
            $sortId[] = $v['sortid'];
        }

        //取唯一sortId
        $unique_sortId = array_unique($sortId);

        //循环取出值
        foreach($unique_sortId as $v){
            $id[] = $v;
        }

        //循环取出间隔自定义时间内和24小时内不在发起的对话记录
        for($i = 0; $i &lt; $len; $i++){
            for($j = $i+1; $j &lt; $len; $j++){
                foreach($id as $v){
                    if($v == $array[$i]['sortid']){
                        if($array[$i]['createuserid'] == $array[$j]['createuserid']){
                            if($array[$i]['endtime'] + 86400 &lt;= $array[$j]['createtime']){
                                // $num++;
                                $sortArr[] = $v;

                            }
                        }
                    }
                }
                //每次对比后跳出循环
                break;
            }
            //获取每条的用户ID
            $arr[$array[$i]['sortid']][] = $array[$i]['createuserid'];
        }
        //循环每个sortId,去重获取总数
        foreach($arr as $k=&gt;$v){
            $count[$k] = count(array_unique($v));
        }
        //取相同值得总数
        $num = array_count_values($sortArr);

        //合并两个数组的值
        foreach($count as $k=&gt;$v){
            foreach($num as $k1=&gt;$v1){
                if($k == $k1){
                    $total[$k] = $v + $v1;
                }else{
                    $total[$k] = $v;
                }
            }
        }
        return $total;
    }</pre>
返回的结果如下图：[![qq20161228-1](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161228-1-300x138.png)](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161228-1.png)

&nbsp;

&nbsp;

&nbsp;

&nbsp;

然后用这个结果来除以接入量，也就是下面的sql语句，当然这个sql查询到的结果也需要通过php来处理。也可以把上面的结果插入到数据库的临时表，通过sql来相除。多种方式可以实现。
<pre class="lang:mysql decode:true ">-- 获取每隔2天的接入量
SELECT 
  floor( (2 - to_days(FROM_UNIXTIME(1470022740)) % 2 + to_days(FROM_UNIXTIME(createTime)) )/2 ) as sortId,
  min(date_format(from_unixtime(createTime),'%y-%m-%d')) as mtime,
  count(kfUserId) as c 
FROM `think_kf_chat_im_group`
  WHERE `endTime` &lt;&gt; 0 
  AND `createTime` BETWEEN 1470022740 
  AND 1470886740  
  and kfUserId &lt;&gt; 0 
GROUP BY sortId;</pre>
结果如下：

![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161228-2.png)

用php来处理刚查询出的数据[
](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161228-2.png)
<pre class="lang:php decode:true ">    /**
     * @param $arr1 array 总接入量
     * @param $arr array 处理过的接入量
     * @return array 返回百分比
     */
    private function processData($arr1,$arr){
        $result = [];
        foreach($arr1 as $k1=&gt;$v1){
            foreach($arr as $k=&gt;$v){
                if($v1['sortid'] == $k){
                    $result[$k1]['mtime'] = $v1['mtime'];
                    $result[$k1]['c'] = floor($v/$v1['c']*100);
                }
            }
        }
        return $result;
    }</pre>
通过highcharts绘画出图形

![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161228-3.png)

&nbsp;
