---
title: Laravel/Lumen 5.4 发送邮件
date: 2017-06-15 07:47:51
tags:
  - sendMail
  - mail
categories:
  - Laravel
  - Lumen
---

### 首先注册邮箱

这里使用163邮箱，个人邮箱需要开启smtp服务

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lqw7xlTgGUbkImUhJ5YsaRdEhz9e.jpeg)

<!--more -->
当勾选设置POP3/SMTP/IMAP时提示需要设置授权码，需要跟登录密码区分开。

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lhhxctrfursOE7MYEXUOCWGprsSk.jpeg)

### 修改配置文件

编辑`.env`文件

```env
MAIL_DRIVER=smtp
MAIL_HOST=smtp.163.com
MAIL_PORT=465
MAIL_USERNAME=test@163.com
MAIL_PASSWORD=******   //这里填写授权码
MAIL_FROM_ADDRESS=test@163.com
MAIL_FROM_NAME=test
MAIL_ENCRYPTION=ssl
```

### 如果是Lumen 需要装mail模块

修改`composer.json` 文件中 `require` 部分配置如下:

```json
"require": {
        "php": ">=5.6.9",
        "laravel/lumen-framework": "5.4.*",
        "vlucas/phpdotenv": "~2.2",
        "guzzlehttp/guzzle": "^6.2",
        "predis/predis": "^1.1",
        "illuminate/redis": "^5.4",
        "illuminate/mail":"5.4.*"
    }
```

并运行`composer install` 来安装 `mail`

### 创建发送邮件命令

如果是`laravel` 直接执行命令，如果是`lumen`自己创建目录和文件

```sh
$ php artisan make:command sendMailCommand
Console command created successfully.
```

创建后生成此文件 `app/Console/Commands/sendMailCommand.php`

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class sendMailCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'mail:sendMailCommand';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = '发送邮件命令';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $content = '这是一封来自Laravel的测试邮件.';
        $toMail  = 'cenhuqing@qq.com';

        Mail::raw($content, function ($message) use ($toMail) {
            $message->subject('[ 测试 ] 测试邮件SendMail - ' .date('Y-m-d H:i:s'));
            $message->to($toMail);
        });
    }
}
```

将命令加入到 `app/Console/Kernel.php`

```php
protected $commands = [
        sendMailCommand::class
];
```

执行命令测试

```sh
$ php artisan |grep send*
  mail:sendMailCommand  发送邮件命令
$ php artisan mail:sendMailCommand                                             
  [Swift_TransportException]                                                                            
  Failed to authenticate on SMTP server with username "test@163.com" using 2 possible authenticators 
```

>注意： 上述执行命令报错，由于验证不通过导致此问题。跟代码没有关系。所以要检查下配置。我在这里找了很久，仍然没有发现错误，最后重置了下授权码后正常。不知道是啥问题。

![file](http://7xlxn7.com1.z0.glb.clouddn.com/ljYep58a1mqSHTr5P1sNg24gLBWc.jpeg)

>问题： 我线上的版本是lumen,每次修改.env配置文件后不会生效，而是使用之前的配置。需要重启后才会生效新配置，不知道是什么原因，也没有配置缓存。如果哪位大神指导请告知下，我的邮箱cenhuqing@gmail.com。 谢谢！
