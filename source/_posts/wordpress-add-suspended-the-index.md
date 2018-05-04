---
title: wordpress添加悬浮文章索引
tags:
  - wordpress
id: 615
categories:
  - Wordpress
date: 2015-10-15 16:50:35
---

文章索引相当于文章目录，点击目录自动跳转到相应位置，这就需要你的文章有小标题，像我经常用h3标签来做小标题，这样所有的h3标签就能形成一个索引目录。我们要做的就是把h3标签自动识别出来并组装成一个目录，好了，开始实现方法。

#### 实现方法
<!-- more -->
在文章里必须有h3标签，每一个三级标题都会成为索引中的一项。将下面的代码放到function.php中，就会在你的文章中自动生成一个索引。

修改functions.php文件，添加如下内容：
<pre class="lang:php decode:true">function article_nav($content)
{
    $matches = array();
    $ul_li = '';
    $r = "/&lt;h3&gt;(.*?)&lt;\/h3&gt;/im";
    if (preg_match_all($r, $content, $matches)) {
        foreach ($matches[1] as $num =&gt; $title) {
            $content = str_replace($matches[0][$num], '&lt;h2 id="article_nav_' . $num . '"&gt;' . $title . '&lt;/h2&gt;', $content);
            $ul_li .= '&lt;li&gt;&lt;a href="#article_nav_' . $num . '" title="' . $title . '"&gt;' . $title . "&lt;/a&gt;&lt;/li&gt;";
        }
        if (is_singular()) {
            $content = '&lt;div id="fn_article_nav"&gt;&lt;div id="article_nav_title"&gt;[文章目录]&lt;/div&gt;&lt;ul&gt;'
                . $ul_li . '&lt;li&gt;&lt;a href="#respond"&gt;发表评论&lt;/a&gt;&lt;/li&gt;&lt;/ul&gt;&lt;/div&gt;' . $content;
        }
    }
    return $content;
}
add_filter("the_content", "article_nav");</pre>

#### 索引样式

索引是生成了，但是只是在文章中的一个普通ul list，我们要做的是把他独立出来，所以只需要为它写一个css样式就好了。推荐用position:fixed把他固定到左边或者右边，下方提供了一个参考样式（见上图），可以根据自己的情况去修改。

修改style.css文件，添加以下内容：
<pre class="lang:css decode:true">/* 文章目录 */
#article_nav_title{font-size:12px;text-align:center;line-height:15px;color:#cc0000;border-left:3px #cc0000 solid;border-bottom:1px #aaa dotted}
#fn_article_nav{position:fixed;left:5px;top:140px;background-color:rgba(255,255,255,.55);border-radius: 0 3px 3px 0;box-shadow:0 0 2px #aaa}
#fn_article_nav ul{padding:0!important;margin:0px!important}
#fn_article_nav li{list-style:none;padding:3px;width:100px;margin:0;background: url("images/li.png") no-repeat scroll 0 5px transparent!important;text-indent: 1.6em;font-size:12px}</pre>

#### 查看效果

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151015-14@2x.png)
