{% if theme.valine.enable and theme.valine.appid and theme.valine.appkey %}
    <script src="//cdn1.lncld.net/static/js/3.0.4/av-min.js"></script>
    <script src='//unpkg.com/valine/dist/Valine.min.js'></script>
    <script>
        new Valine({
            av: AV,
            el: '#vcomments',
            notify: {{ theme.valine.notify }},
            verify: {{ theme.valine.verify }},
            app_id: '{{ theme.valine.appid }}', // 这里填写上面得到的APP ID
            app_key: '{{ theme.valine.appkey }}', // 这里填写上面得到的APP KEY
            placeholder: '{{ theme.valine.placeholder }}', // [v1.0.7 new]留言框占位提示文字
            avatar: '{{ theme.valine.avatar }}'
        });
   </script>
{% endif %}
