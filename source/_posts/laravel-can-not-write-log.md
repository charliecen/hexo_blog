---
title: Laravel log 无法写入问题
date: 2017-05-10 09:38:04
tags:
  - logs
  - queue
  - 日志无法写入
categiores:
  - Laravel
---

### 问题1

账号登录报500错误，也没有返回错误信息，没办法只能使用原始方法，到现在一行一行打印。到 `Log::info()` 后面就无法正常显示了，那么问题就找到了。

导致无法写入日志的问题，是由于代码更新时添加了文件是`root`用户，所以创建日志文件也是`root`权限，导致其它用户的`www`权限无法写入日志文件中。
<!-- more-->
所以修改`storage/logs/`的用户权限为`www`

```sh
chown www:www storage/logs -R
```

>注意：如果用户使用supervisord服务运行队列的话，如果队列里有日志记录，那么运行的用户也需要改成`www`用户。


### 问题2

同样是日志无法记录问题，这里是本地环境使用`php artisan queue:work --sleep=3 --tries=3`运行。

同样在`job`中写日志，权限也是正确，就是无法记录日志，任务也正常执行。

最后想到重启队列解决此问题，不知道是什么原因导致。如果有知道的同学请告知一声。

重启队列命令

```sh
php artisan queue:restart

```

### 其它与日志无关的问题

#### 问题1
最近在使用 Zizaco\Entrust 这个权限包...

再添加角色的时候... 报了一个错..

```log
BadMethodCallException in Repository.php line 391:
This cache store does not support tagging.
```

应该是这个包里 有个地方用了 laravel 的cache,默认的cache是file

把.env 里的 CACHE_DRIVER 改成

CACHE_DRIVER=array

#### 问题2
页面出现此错误

```log
View [.] not found.
```

解决办法，优化，清除配置缓存，路由缓存

```sh
php artisan optimize --force
php artisan config:cache
php artisan route:cache
```

