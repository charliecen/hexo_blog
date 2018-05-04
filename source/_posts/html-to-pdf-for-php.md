---
title: html-to-pdf-for-php
tags:
  - highcharts to pdf
  - html to pdf
  - sh_exec()
  - wkhtmltopdf
  - 页面生成pdf
id: 836
categories:
  - Dev
  - JavaScript
  - PHP
date: 2016-12-01 18:54:34
---

需求：报表页面点击下载后转成pdf文件；

之前找了很多插件，用下来wkhtmltopdf最好用；

下面说下如何操作

首先下载插件，最好翻墙下载，不然很慢，最好下载tar.gz包，不要到github上clone,文件太大；
<pre class="lang:sh decode:true">http://wkhtmltopdf.org/downloads.html</pre>
![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161201-0.png)
<!-- more -->
拷贝文件到命令目录
<pre class="lang:sh decode:true ">tar xf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
cd wkhtmltox/bin
cp wkhtmltopdf /usr/local/bin/
</pre>
html页面
<pre class="lang:xhtml decode:true ">&lt;button class="btn-success btn button" style="margin-left: 85%" onclick="print_pdf()"&gt;下载PDF&lt;/button&gt;
&lt;form action="&lt;?php echo U('Custorm/savePdf') ?&gt;" method="post" name="hld_res" id="hideform"&gt;
  &lt;input type="hidden" id="hide_content" name="content" /&gt;
  &lt;input type="hidden" name="title" value="&lt;?php echo $data[0]['title']?&gt;"/&gt;
&lt;/form&gt;</pre>
JS方法
<pre class="lang:sh decode:true ">function print_pdf(){
            //下载范围
            bdhtml=window.document.body.innerHTML;
            sprnstr="&lt;!--startprint--&gt;";
            eprnstr="&lt;!--endprint--&gt;";
            prnhtml=bdhtml.substring(bdhtml.indexOf(sprnstr)+17);
            prnhtml=prnhtml.substring(0,prnhtml.indexOf(eprnstr));
//            将获取的html代码添加到隐藏域中传给php文件处理
            $("#hide_content").val(""+prnhtml+"");
            $("#hideform").submit();
        }</pre>
PHP方法
<pre class="lang:php decode:true">public function savePdf()
    {
        $html = $_REQUEST['content'];
        ob_start();
        $html='
        &lt;html&gt;
        &lt;link href="http://your_domain_name/Public/css/style.css" rel="stylesheet"&gt;
        &lt;link href="http://your_domain_name/Public/css/style-responsive.css" rel="stylesheet"&gt;
        &lt;link type="text/css" rel="stylesheet" href="http://your_domain_name/Public/js/bootstrap-table/bootstrap-table.css"&gt;
        &lt;meta http-equiv="Content-Type" content="text/html; charset=utf-8" /&gt; 
        &lt;body style="background: white;"&gt; '.$html;
        $html .= ' &lt;/body&gt;&lt;/html&gt;';
        $filename = $_REQUEST['title'] ? $_REQUEST['title'] : '报表-'.date('Y-m-d');
        file_put_contents("{$filename}.html", $html);
        ob_end_clean();
        //转换HTML TO PDF
        sh_exec("/usr/local/bin/wkhtmltopdf -q -s A2 -O Landscape {$filename}.html {$filename}.pdf");
        if(file_exists("{$filename}.pdf")){
            header('Content-type:application/octet-stream');
            header("Content-Disposition:attachment;filename={$filename}.pdf");
            header('Content-Length:'.filesize("{$filename}.pdf"));
            readfile("{$filename}.pdf");
            //删除本地的文件
            unlink("{$filename}.pdf");
            unlink("{$filename}.html");
        }else{
            exit;
        }
    }</pre>
pdf文档效果

![](http://blog.cenhq.com/wp-content/uploads/2016/12/QQ20161201-1.png)

效果还是不错的；

这里遇到一个问题，就是线上的sh_exec()函数不执行。改目录权限，改sudo配置等等，都没效果，然后去配置文件里查看php.ini, 里面添加了disable_functions，去掉你要用的函数就可以了。

参考：http://blog.csdn.net/qq_14873105/article/details/51394026
