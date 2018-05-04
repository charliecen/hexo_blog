---
title: WP-Postviews使用
tags:
  - wordpress
  - WP-PostViews
id: 586
categories:
  - Wordpress
date: 2015-10-12 17:59:31
---

今天换了个主题，顺便把浏览次数在文章下显示效果弄出来。

首先到插件里下载

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151012-2@2x.jpg)

然后启用该插件

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151012-1@2x.jpg)
<!-- more -->
到设置里找到postviews

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151012-3@2x.jpg)
<div>1）Count Views From: 设置统计数据来源，可选项：所有人、仅访客、仅注册用户，默认：仅访客。</div>
<div></div>
<div>2）Exclude Bot Views: 是否排除搜索机器人（搜索引擎蜘蛛程序）的浏览数量，可选项：是、否，默认：否。</div>
<div></div>
<div>3）Views Template: 浏览数统计的显示模板，默认是：%VIEW_COUNT% views ，%VIEW_COUNT%变量表示浏览次数，views是固定显示文本。比如，默认会显示为“3 views”，我们可以更改其显示样式，如果要显示为“热度：3度”，我们可以将其改为“热度：%VIEW_COUNT%度”。</div>
<div></div>
<div>4）Most viewed Template: 网站Widget（微件）显示热门文章列表的模板。默认HTML格式是：&lt;li&gt;&lt;a href="%POST_URL%" title="%POST_TITLE%"&gt;%POST_TITLE%&lt;/a&gt; - %VIEW_COUNT% views&lt;/li&gt;。其中，%POST_URL%是文章地址，%POST_TITLE%文章标题，%VIEW_COUNT%是浏览次数。我们可以更改成为自己想要的样式，比如个人博客的样式为：&lt;li&gt;&lt;a href="%POST_URL%"&gt;%POST_TITLE%&lt;/a&gt;&lt;cite&gt;(%VIEW_COUNT%)&lt;/cite&gt;&lt;/li&gt;，完全根据自己需求来设置。</div>
<div></div>
<div>5）Display Options: 设置哪些页面可以显示浏览数统计，也可以指定给哪些人显示。其中，页面包括“Home page”主页、“single Posts”文章页、“Pages”页面、“Archive Pages”分类目录归档页、“Search Pages”搜索页、“Other Pages”其它页面，都可以独立配置。另个，每个配置下面都有三个选项可供选择：“Display to everyone”显示给所有人、“Display to registered users only”只显示给注册用户、“Don’t display on archive pages”不显示。</div>
<div></div>
<div>6）Uninstall WP-PostViews：WP-Postviews插件卸载。执行卸载后，WordPress Options/PostMetas数据表中的相关插件信息也将删除掉。</div>
<div></div>
<div>
<div>**WP-Postviews插件使用方法：调用日志浏览统计**</div>
<div></div>
<div>这是WP-Postviews插件的基本使用方法。如果想在你的主题上实现文章点击数，办法很简单，只需要在你的主题模板single.php或loop的相应位置加入以下代码即可：</div>
<div>
<pre class="lang:php decode:true ">&lt;?php if(function_exists('the_views')) { the_views(); } ?&gt;</pre>
本人使用该方法：
<pre class="lang:sh decode:true">cd /data/www/wwwroot/cenhq/wp-content/themes/travelify
vim library/structure/content-extensions.php
#修改一下内容，找到the_posts，在category后面添加代码，我列出的比较多。'…'为省略内容
function travelify_theloop_for_archive() {
    global $post;

    if( have_posts() ) {
        while( have_posts() ) {
            the_post();

            do_action( 'travelify_before_post' );
?&gt;
...
...
...
    &lt;div class="entry-meta-bar clearfix"&gt;
                &lt;div class="entry-meta"&gt;
                        &lt;?php travelify_posted_on(); ?&gt;
                        &lt;?php if( has_category() ) { ?&gt;
                        &lt;span class="category"&gt;&lt;?php the_category(', '); ?&gt;&lt;/span&gt;
                    &lt;?php } ?&gt;
                        &lt;?php if ( comments_open() ) { ?&gt;
                        &lt;?php if(function_exists('the_views')) { the_views(); } ?&gt;
                        &lt;span class="comments"&gt;&lt;?php comments_popup_link( __( 'No Comments', 'travelify' ), __( '1 Comment', 'travelify' ), __( '% Comments', 'travelify' ), '', __( 'Comments Off', 'travelify' ) ); ?&gt;&lt;/span&gt;
                    &lt;?php } ?&gt;
                &lt;/div&gt;&lt;!-- .entry-meta --&gt;
                &lt;?php
                echo '&lt;a class="readmore" href="' . get_permalink() . '" title="'.the_title( '', '', false ).'"&gt;'.__( 'Read more', 'travelify' ).'&lt;/a&gt;';
                ?&gt;
            &lt;/div&gt;

function travelify_theloop_for_single() {
    global $post;

    if( have_posts() ) {
        while( have_posts() ) {
            the_post();

            do_action( 'travelify_before_post' );
?&gt;
...
...
...
    &lt;div class="entry-meta-bar clearfix"&gt;
                &lt;div class="entry-meta"&gt;
                        &lt;?php travelify_posted_on(); ?&gt;
                        &lt;?php if( has_category() ) { ?&gt;
                        &lt;span class="category"&gt;&lt;?php the_category(', '); ?&gt;&lt;/span&gt;
                    &lt;?php } ?&gt;
                        &lt;?php if(function_exists('the_views')) { the_views(); } ?&gt;
                        &lt;?php if ( comments_open() ) { ?&gt;
                        &lt;span class="comments"&gt;&lt;?php comments_popup_link( __( 'No Comments', 'travelify' ), __( '1 Comment', 'travelify' ), __( '% Comments', 'travelify' ), '', __( 'Comments Off', 'travelify' ) ); ?&gt;&lt;/span&gt;
                    &lt;?php } ?&gt;
                &lt;/div&gt;&lt;!-- .entry-meta --&gt;
            &lt;/div&gt;</pre>
第一个函数修改完效果：

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151012-6@2x.jpg)

第二个函数修改完效果：

![](http://blog.cenhq.com/wp-content/uploads/2015/10/QQ20151012-7@2x.jpg)

</div>
</div>
