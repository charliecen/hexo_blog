---
title: wordpress添加ClustrMaps
tags:
  - ClustrMaps
  - wordpress
id: 627
categories:
  - Wordpress
date: 2015-10-16 14:44:01
---

首先到[http://www.clustrmaps.com/zh/index.htm](http://www.clustrmaps.com/zh/index.htm)生成自己的地图
<div>然后注册登录账号，获取地图代码</div>
<div></div>
<div>根据主题布局放置代码位置，这里我放在右侧。</div>
<div>编辑文件sidebar-right.php,添加以下内容：</div>
<div>
<pre class="lang:php decode:true ">&lt;!--ClusterMap--&gt;
&lt;aside class="widget"&gt;&lt;h3 class="widget-title"&gt;统计&lt;/h3&gt;&lt;div id="clustrmaps-widget"&gt;&lt;/div&gt;&lt;script type="text/javascript"&gt;var _clustrmaps = {'url' : 'http://blog.cenhq.com', 'user' : 1181037, 'server' : '3', 'id' : 'clustrmaps-widget', 'version' : 1, 'date' : '2015-10-16', 'lang' : 'zh', 'corners' : 'square' };(function (){ var s = document.createElement('script'); s.type = 'text/javascript'; s.async = true; s.src = 'http://www3.clustrmaps.com/counter/map.js'; var x = document.getElementsByTagName('script')[0]; x.parentNode.insertBefore(s, x);})();&lt;/script&gt;&lt;noscript&gt;&lt;a href="http://www3.clustrmaps.com/user/f5e12056d"&gt;&lt;img src="http://www3.clustrmaps.com/stats/maps-no_clusters/blog.cenhq.com-thumb.jpg" alt="Locations of visitors to this page" /&gt;&lt;/a&gt;&lt;/noscript&gt;&lt;/div&gt;&lt;/aside&gt;</pre>
<div>效果显示：</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151016-3@2x.png)</div>
</div>