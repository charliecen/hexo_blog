---
title: Laravel 安装第三方包 Mongodb报错
date: 2017-03-28 10:03:19
tags:
  - mongodb
  - php56-mongodb
  - php56-mongo
  - _clock_gettime
  - mongodb-1.2.8
categories:
  - Laravel
---


由于项目使用mongodb数据库来存储数据，所以需要第三方包mongodb来配合；这里使用`composer`来安装。

#### 安装`jenssegers/mongodb`报错

<!-- more -->
```
 $ composer require jenssegers/mongodb:3.2.*
./composer.json has been updated
Loading composer repositories with package information
Updating dependencies (including require-dev)
Your requirements could not be resolved to an installable set of packages.

  Problem 1
    - jenssegers/mongodb v3.2.0 requires mongodb/mongodb ^1.0.0 -> satisfiable by mongodb/mongodb[1.0.0, 1.0.0-alpha1, 1.0.0-beta1, 1.0.0-beta2, 1.0.1, 1.0.2, 1.0.3, 1.0.4, 1.0.5, 1.1.0, 1.1.0-alpha1, 1.1.1, 1.1.2, 1.2.0-alpha1, 1.2.x-dev, v1.0.x-dev, v1.1.x-dev].
    - jenssegers/mongodb v3.2.1 requires mongodb/mongodb ^1.0.0 -> satisfiable by mongodb/mongodb[1.0.0, 1.0.0-alpha1, 1.0.0-beta1, 1.0.0-beta2, 1.0.1, 1.0.2, 1.0.3, 1.0.4, 1.0.5, 1.1.0, 1.1.0-alpha1, 1.1.1, 1.1.2, 1.2.0-alpha1, 1.2.x-dev, v1.0.x-dev, v1.1.x-dev].
    - jenssegers/mongodb v3.2.2 requires mongodb/mongodb ^1.0.0 -> satisfiable by mongodb/mongodb[1.0.0, 1.0.0-alpha1, 1.0.0-beta1, 1.0.0-beta2, 1.0.1, 1.0.2, 1.0.3, 1.0.4, 1.0.5, 1.1.0, 1.1.0-alpha1, 1.1.1, 1.1.2, 1.2.0-alpha1, 1.2.x-dev, v1.0.x-dev, v1.1.x-dev].
    - mongodb/mongodb v1.1.x-dev requires ext-mongodb ^1.2.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb v1.0.x-dev requires ext-mongodb ^1.1.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.2.x-dev requires ext-mongodb ^1.2.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.2.0-alpha1 requires ext-mongodb ^1.2.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.1.2 requires ext-mongodb ^1.2.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.1.1 requires ext-mongodb ^1.2.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.1.0-alpha1 requires ext-mongodb ^1.1.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.1.0 requires ext-mongodb ^1.2.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.5 requires ext-mongodb ^1.1.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.4 requires ext-mongodb ^1.1.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.3 requires ext-mongodb ^1.1.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.2 requires ext-mongodb ^1.1.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.1 requires ext-mongodb ^1.1.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.0-beta2 requires ext-mongodb ^1.1.1 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.0-beta1 requires ext-mongodb ^1.0.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.0-alpha1 requires ext-mongodb ^1.0.0 -> the requested PHP extension mongodb is missing from your system.
    - mongodb/mongodb 1.0.0 requires ext-mongodb ^1.1.0 -> the requested PHP extension mongodb is missing from your system.
    - Installation request for jenssegers/mongodb 3.2.* -> satisfiable by jenssegers/mongodb[v3.2.0, v3.2.1, v3.2.2].

  To enable extensions, verify that they are enabled in your .ini files:
    - /usr/local/etc/php/5.6/php.ini
    - /usr/local/etc/php/5.6/conf.d/ext-igbinary.ini
    - /usr/local/etc/php/5.6/conf.d/ext-memcached.ini
    - /usr/local/etc/php/5.6/conf.d/ext-mongo.ini
    - /usr/local/etc/php/5.6/conf.d/ext-redis.ini
    - /usr/local/etc/php/5.6/conf.d/ext-ssh2.ini
    - /usr/local/etc/php/5.6/conf.d/ext-xdebug.ini
  You can also run `php --ini` inside terminal to see which files are used by PHP in CLI mode.

Installation failed, reverting ./composer.json to its original content.

```

##### 报错解析
第三方包需要`php56-mongodb`扩展，本机只有`php56-mongo`扩展，所以需要继续安装 `php56-mongodb`。

```sh
$ brew install php56-mongodb                                                                                                                                 
Error: /usr/local/opt/php56-mongodb is not a valid keg
```

这个错误说明`php56-mongodb`目录不是有效的桶， 所以删除这个目录继续安装就可以

```sh
$ sudo rm -rf /usr/local/opt/php56-mongodb
$ brew install php56-mongodb
$ php -i "(command-line 'phpinfo()')" |grep mongodb
/usr/local/etc/php/5.6/conf.d/ext-mongodb.ini,
mongodb
mongodb.debug => no value => no value
```

再次安装第三方包

```sh
$ composer require jenssegers/mongodb
cUsing version ^3.2 for jenssegers/mongodb
./composer.json has been updated
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 2 installs, 0 updates, 0 removals
  - Installing mongodb/mongodb (1.1.2): Downloading (100%)         
  - Installing jenssegers/mongodb (v3.2.2): Downloading (100%)         
jenssegers/mongodb suggests installing jenssegers/mongodb-session (Add MongoDB session support to Laravel-MongoDB)
jenssegers/mongodb suggests installing jenssegers/mongodb-sentry (Add Sentry support to Laravel-MongoDB)
Writing lock file
Generating autoload files
```


#### php调用mongodb挂掉

```sh
dyld: lazy symbol binding failed: Symbol not found: _clock_gettime
  Referenced from: /usr/local/opt/php56-mongodb/mongodb.so
  Expected in: /usr/lib/libSystem.B.dylib

dyld: Symbol not found: _clock_gettime
  Referenced from: /usr/local/opt/php56-mongodb/mongodb.so
  Expected in: /usr/lib/libSystem.B.dylib

[1]    29551 trace trap  php -S 192.168.82.195:8989
```

##### 解决办法
<https://github.com/Homebrew/homebrew-php/issues/3737>

```
make sure you have the latest version of xcode-select,mine is 2343 xcode-select -v,if not update then restart your mac

 brew edit {formula} #formula likes php71-mongodb

 edit it，add lines after “install”, may like this
def install
Dir.chdir "mongodb-#{version}" unless build.head?
if MacOS.version == "10.11" && MacOS::Xcode.installed? && MacOS::Xcode.version >= "8.0"
inreplace %w[src/libbson/src/bson/bson-clock.c], "HAVE_CLOCK_GETTIME", "UNDEFINED_GIBBERISH"`
end

 reinstall php71-mongodb from source brew reinstall -s php71-mongodb
```

上面的英文解释下：

* `xcode-select` 最新的版本为：2343，如果不是需要升级
* 编辑`php56-mongodb`,修改位置大概在20行下面，添加此内容 `if MacOS.version == "10.11" && MacOS::Xcode.installed? && MacOS::Xcode.version >= "8.0"
inreplace %w[src/libbson/src/bson/bson-clock.c], "HAVE_CLOCK_GETTIME", "UNDEFINED_GIBBERISH"
end`
* 然后重新安装 `php56-mongodb`

> 但是重装会无法执行，报错timeout超时。而且下载的是版本为`mongodb-1.2.5`，所以我们需要最新版本`mongodb-1.2.8`需要手动下载。

[下载地址](https://github.com/mongodb/mongo-php-driver/releases/download/1.2.8/mongodb-1.2.8.tgz)

###### 安装

```sh
$ tar xf mongodb-1.2.8.tgz
$ cd mongodb-1.2.8
$ phpize
$ ./configure
$ make
```
###### 报如下错误

```sh
/Users/zt-2203315/Downloads/资源包/mongodb-1.2.8/src/libmongoc/src/mongoc/mongoc-crypto-openssl.c:24:10: fatal error: 'openssl/sha.h' file not found
#include <openssl/sha.h>
```

###### 需要升级openssl,并且执行软连接

```sh
$ brew install openssl --force
$ cd /usr/local/include 
$ ln -s ../opt/openssl/include/openssl .
```

###### 继续安装

```sh
$ make clean
$ make
$ make install
Installing shared extensions:     /usr/local/Cellar/php56/5.6.30_6/lib/php/extensions/no-debug-non-zts-20131226/

$ php --ini
Configuration File (php.ini) Path: /usr/local/etc/php/5.6
Loaded Configuration File:         /usr/local/etc/php/5.6/php.ini
Scan for additional .ini files in: /usr/local/etc/php/5.6/conf.d
Additional .ini files parsed:      /usr/local/etc/php/5.6/conf.d/ext-igbinary.ini,
/usr/local/etc/php/5.6/conf.d/ext-memcached.ini,
/usr/local/etc/php/5.6/conf.d/ext-mongo.ini,
/usr/local/etc/php/5.6/conf.d/ext-mongodb.ini,
/usr/local/etc/php/5.6/conf.d/ext-redis.ini,
/usr/local/etc/php/5.6/conf.d/ext-ssh2.ini,
/usr/local/etc/php/5.6/conf.d/ext-xdebug.ini

```

###### 修改扩展配置

```sh
$ vim /usr/local/etc/php/5.6/conf.d/ext-mongodb.ini
extension="/usr/local/Cellar/php56/5.6.30_6/lib/php/extensions/no-debug-non-zts-20131226/mongodb.so"
```

###### 保存后重启服务

```sh
$ killall php-fpm
$ php-pfm -D
```

###### 数据库配置`config/database.php`

```php
return [

    'default' => env('DB_CONNECTION', 'mysql'),

    'connections' => [
        'mysql' => [
            'driver'    => 'mysql',
            'host'      => env('DB_HOST', 'localhost'),
            'database'  => env('DB_DATABASE', 'lumen'),
            'username'  => env('DB_USERNAME', 'root'),
            'password'  => env('DB_PASSWORD', 'charlie'),
            'charset'   => 'utf8',
            'collation' => 'utf8_unicode_ci',
            'prefix'    => '',
            'strict'    => false,
        ],

        'mongodb' => [
            'driver'   => 'mongodb',
            'host'     => 'localhost',
            'port'     => 27017,
            'database' => 'test',
            'username' => env(''),
            'password' => env(''),
            'options'  => [
                'database' => 'admin' // sets the authentication database required by mongo 3
            ]
        ],

    ],
];
```

###### 注册服务`bootstrap/app.php`

```php
$app->configure('database');

$app->register(\Jenssegers\Mongodb\MongodbServiceProvider::class);

$app->withEloquent();
```


###### 创建测试模型`app/Model/Test.php`

```php
namespace App\Model;


use Jenssegers\Mongodb\Eloquent\Model;

class Test extends Model
{
    protected $connection = 'mongodb';

    protected $collection = 'c2';
}
```

###### 创建测试控制器`app/Http/Controllers/TestController.php`

```php
namespace App\Http\Controllers;

use App\Model\Test;
use Illuminate\Support\Facades\DB;

class TestController extends Controller
{
    public function index()
    {
//        $test = DB::connection('mongodb')->collection('c2')->get();
        $test = Test::all()->toArray();
        echo '<pre>';
        print_r($test);
    }
}
```

###### 创建路由`routes/web.php`

```php
$app->get('aa', 'TestController@index');

```

###### 访问页面

```php
Array
(
    [0] => Array
        (
            [_id] => 5837d39d05045864010041bd
            [ym] => 2016年/11月
            [date] => 2016/11/25
            [key_time] => tmp_look_1480047736
            [title] => test18
            [status] => 已发布
        )

)
```
