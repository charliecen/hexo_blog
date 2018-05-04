---
title: mysql查询日期间隔自定义日期
tags:
  - mysql日期间隔查询
  - todays
  - 天数排序
  - 自定义时间间隔
categories:
  - Dev
  - Mysql
  - PHP
date: 2016-12-06 17:32:35
---

需求：由于查询日期范围内数据，需要定义日期范围内数据的单位，比如从2016年11月1日到2016年12月10日，间隔为5天，也就是11月1日，11月6日，11月11日。。。
<!-- more -->
这里要用到mysql函数，如下：
<pre class="lang:mysql decode:true ">DELIMITER $$
create function getTimeSortId(timetype varchar(20),startTime datetime,usetime datetime,splitNum int(10))
returns int(10)
begin
declare sortId int;
set sortId = 0;
if timetype = "day" then
	set sortId = floor( (splitNum - to_days(startTime) % splitNum + to_days(usetime) )/splitNum ); 
end if;
if timetype = "week" then
	set sortId = floor((splitNum - floor((TO_DAYS(startTime) + 5 )/7) % splitNum + floor((TO_DAYS(usetime) + 5 )/7) )/splitNum);
end if;
if timetype = "month" then
	set sortId = floor((splitNum -  ( month(startTime) + year(startTime) * 12) % splitNum + ( month(usetime) + year(usetime) * 12) )/splitNum);
end if;
return sortId;
end $$
DELIMITER ;
</pre>
解释下函数内容：

getTimeSortId为函数，timetype : 日期类型，startTime ： 开始时间，usetime : 字段时间，splitNum : 间隔数；

如果传递的参数为天，间隔数 - 转化为天的开始时间 % 间隔数 + 转化为天的字段时间 / 间隔数 = 排序ID

下面周跟月就具体介绍了；

具体运行如下：
<pre class="lang:mysql decode:true">select 
  getTimeSortId('day',from_unixtime(1470109260,'%y-%m-%d'),from_unixtime(createTime,'%y-%m-%d'),3) as sortId,
  min(from_unixtime(createTime,'%y-%m-%d')) as mtime,
  count(*) from think_kf_chat_im_group 
where createTime BETWEEN 1470109260 AND 1472442060 
group by sortId;</pre>
![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161206-0.png)

到数据库中运行，查看生成的语法
<pre class="lang:mysql decode:true ">CREATE DEFINER=`root`@`localhost` FUNCTION `getTimeSortId`(timetype varchar(20),startTime datetime,usetime datetime,splitNum int(10)) RETURNS int(10)
begin
declare sortId int;
declare totalDay int;
declare totalMonth int;
declare totalYear int;
set sortId = 0;
if timetype = "day" then
	set sortId = floor( (splitNum - to_days(startTime) % splitNum + to_days(usetime) )/splitNum ); 
end if;
if timetype = "week" then
	set sortId = floor((splitNum - floor((TO_DAYS(startTime) + 5 )/7) % splitNum + floor((TO_DAYS(usetime) + 5 )/7) )/splitNum);
end if;
if timetype = "month" then
	set sortId = floor((splitNum -  ( month(startTime) + year(startTime) * 12) % splitNum + ( month(usetime) + year(usetime) * 12) )/splitNum);
end if;
return sortId;
end;</pre>
如果不是root用户的话，会有权限问题；

我这里数据库有的不是root用户，所以要把这个函数放到php里定义成一个方法，然后调用生成sql语句来执行；
<pre class="lang:php decode:true ">/**
     * @param type day week month
     * @param startTime 开始时间,必须是时间戳
     * @param key 时间字段
     * @param asName 生成的ID
     * @param isTimestamp key是否为时间戳
     * @param echo $this-&gt;getSortId("week", 1477929600, "intitime", 2, "sortId", false);
     */
    protected function getSortId($type, $startTime, $key, $splitNum, $asName = "sortId", $isTimestamp = false)
    {
        if ($isTimestamp) {
            $key = "FROM_UNIXTIME(" . $key . ")";
        }

        $startTime = "FROM_UNIXTIME(" . $startTime . ")";

        if ($type == "day") {
            $sql = "floor( (" . $splitNum . " - to_days(" . $startTime . ") % " . $splitNum . " + to_days(" . $key . ") )/" . $splitNum . " ) as " . $asName . " ";
        } else if ($type == "week") {
            $sql = "floor((" . $splitNum . " - floor((TO_DAYS(" . $startTime . ") + 5 )/7) % " . $splitNum . " + floor((TO_DAYS(" . $key . ") + 5 )/7) )/" . $splitNum . ") as " . $asName . " ";
        } else if ($type == "month") {
            $sql = "floor((" . $splitNum . " -  ( month(" . $startTime . ") + year('" . $startTime . "') * 12) % " . $splitNum . " + ( month(" . $key . ") + year('" . $key . "') * 12) )/" . $splitNum . ") as " . $asName . " ";
        } else {
            $sql = "(0) as " . $asName . " ";
        }
        return $sql;
    }</pre>
调用次方法来生成field
<pre class="lang:php decode:true ">/**
     * 根据日期间隔统计数据
     * @param $dateFormat int 间隔数字
     * @param $dateUtil string 间隔单位,如:天,周,月,年
     * @param $sTime int | datetime 开始时间
     * @param $dateField string 日期字段名
     * @param $opertion string 统计数量
     * @param $groupType string 日期类型
     * echo $this-&gt;setIntervalTime(3,'day',1477929600,'createTime','count(*)','day');
     */
    private function setIntervalTime($dateFormat,$dateUtil,$sTime,$dateField,$opertion,$groupType,$isTimestamp = true)
    {
        if(is_numeric($dateFormat) &amp;&amp; is_string($dateUtil)){
            if(!is_int($sTime)){
                $sTime =  strtotime($sTime);
            }
            $field = $this-&gt;getSortId($dateUtil,$sTime,$dateField,$dateFormat,"sortId",$isTimestamp) .
                ",min(date_format(" .
                    ($isTimestamp ? "from_unixtime(" . $dateField . ")" : $dateField).
                ",'".$this-&gt;getGroupFormat($groupType)."')) as mtime,".
                $opertion." as c";
        }else{
            $this-&gt;error('你输入的日期单位或日期格式不正确');
            exit;
        }
        return $field;
    }</pre>
具体调用如下：
<pre class="lang:php decode:true ">$field = $this-&gt;setIntervalTime($dateFormat,$dateUnit,$sTime,'createTime','count(*)',$groupType);
$where['createTime'] = array('between',array($sTime,$eTime));
$model-&gt;field($field)-&gt;where($where)-&gt;group('sortId')-&gt;select();</pre>
获取的数据到通过highcharts到前端显示如下

![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161206-1.png)

&nbsp;

感谢同事鹏哥的帮助；大家有好的方法，求留言讨论；
