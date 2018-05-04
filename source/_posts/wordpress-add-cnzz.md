---
title: wordpress添加CNZZ统计
tags:
  - cnzz
  - wordpress
id: 622
categories:
  - Wordpress
date: 2015-10-16 14:40:00
---

<div>首先注册cnzz用户，并绑定网站域名</div>
<div>获取统计代码，复制代码到主题里的footer.php文件里</div>
<!-- more -->
<div>然后位置显示有问题</div>
<div>![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151016-0@2x.png)</div>
<div>
<div>我想把图标移动到wordpress后面</div>
<div>首先注释footer.php里的CNZZ统计代码</div>
<div>然后编辑文件library/structure/footer-extensions.php</div>
<div>编辑后的内容如下：</div>
<div>
<pre class="lang:php decode:true ">function travelify_footer_info() {
     echo '&lt;div class="copyright"&gt;';
     echo __( 'Copyright &amp;copy;', 'travelify' );
     echo ' '.date('Y');
     echo ' '.travelify_site_link();
     echo '. '.__( 'Theme by', 'travelify' );
     echo ' '.travelify_colorlib_link(    );
     echo ' '.__( 'Powered by', 'travelify' );
     echo ' '.travelify_wp_link();
     echo '&lt;div class="cnzz_tj" style="
    display: inline-block;
    vertical-align: middle;
    margin-left: 5px;
    line-height: 13px;
"&gt;统计使用：';
     echo '&lt;script type="text/javascript"&gt;var cnzz_protocol = (("https:" == document.location.protocol) ? " https://" : " http://");document.write(unescape("%3Cspan id=\'cnzz_stat_icon_1256550401\'%3E%3C/span%3E%3Cscript src=\'" + cnzz_protocol + "s4.cnzz.com/z_stat.php%3Fid%3D1256550401%26show%3Dpic\' type=\'text/javascript\'%3E%3C/script%3E"));&lt;/script&gt;';
     echo '&lt;/div&gt;';
     echo '&lt;/div&gt;&lt;!-- .copyright --&gt;';
  }</pre>
保存后刷新页面

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151016-2@2x.png)

</div>
</div>
