---
title: lumen 部署到线上遇到的问题
date: 2017-04-14 06:14:56
tags:
  - signle
  - lumen.log
  - daily
  - header
  - proc_open
cateoriges:
  - Lumen
---

### lumen 默认的日志保存模式是single

也就是单文件模式

要想改成每日的daily模式可以在bootstrap/app.php下添加：

```php
/*
 * 配置日志文件为每日
 */
$app->configureMonologUsing(function(Monolog\Logger $monoLog) use ($app){
    return $monoLog->pushHandler(
        new \Monolog\Handler\RotatingFileHandler($app->storagePath().'/logs/lumen.log',5)
    );
});
```
<!--more -->

### lumen nginx 允许自定义header

nginx是支持读取非nginx标准的用户自定义header的，但是需要在http或者server下开启header的下划线支持:

```sh
underscores_in_headers on;
```

### 错误信息

#### 错误1

```php
[Symfony\Component\Process\Exception\RuntimeException]                                   
  The Process class relies on proc_open, which is not available on your PHP installation.
```

解决办法：
打开`php.ini`，并搜索`disable_functions`指令，找到类似如下内容：

```ini
disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server
```

找到`proc_open`并删除即可。

