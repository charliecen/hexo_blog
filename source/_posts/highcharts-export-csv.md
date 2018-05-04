---
title: highcharts导出csv格式
tags:
  - export-csv
  - exporting
  - highcharts
id: 820
categories:
  - JavaScript
date: 2016-09-27 10:56:17
---

业务需求报表导出格式为CSV，所以需要引用export-csv.js和exporting.js
<!-- more -->
代码如下:
<pre class="lang:js decode:true ">&lt;script src="http://code.highcharts.com/stock/highstock.js"&gt;&lt;/script&gt;
&lt;script src="http://code.highcharts.com/modules/exporting.js"&gt;&lt;/script&gt;
&lt;script src="http://highcharts.github.io/export-csv/export-csv.js"&gt;&lt;/script&gt;
&lt;div id="container" style="height: 300px; margin-top: 2em"&gt;&lt;/div&gt;
&lt;script&gt;
var chart = new Highcharts.StockChart({
    chart: {
        renderTo: 'container'
    },
    navigator: {
        series: {
            includeInCSVExport: false
        }
    },
    series: [{
        data: [29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4],
        pointStart: Date.UTC(2016, 0, 1),
        pointInterval: 24 * 36e5
    }],

    exporting: {
        csv: {
            dateFormat: '%Y-%m-%d'
        }
    }

});
&lt;/script&gt;</pre>
显示效果：

![](http://blog.cenhq.com/wp-content/uploads/2016/09/QQ20160927-0.png)

导出结果：

![](http://blog.cenhq.com/wp-content/uploads/2016/09/QQ20160927-1.png)

参考：https://github.com/highcharts/export-csv
