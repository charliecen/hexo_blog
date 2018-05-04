---
title: Laravel Passport 使用
date: 2017-07-19 13:32:01
tags:
  - Passport
categories:
  - Laravel
---

### 简介
在 Laravel 中，实现基于传统表单的登陆和授权已经非常简单，但是如何满足 API 场景下的授权需求呢？在 API 场景里通常通过令牌来实现用户授权，而非维护请求之间的 Session 状态。现在 Laravel 项目中可以使用 Passport 轻而易举地实现 API 授权过程，通过 Passport 可以在几分钟之内为你的应用程序添加完整的 OAuth2 服务端实现。 Passport 基于` League OAuth2 server` 实现。
<!--more -->
### 安装

使用 Composer 依赖包管理器安装 Passport ：

```sh
composer require laravel/passport
```

接下来，将 Passport 的服务提供者注册到配置文件 `config/app.php` 的 `providers` 数组中：

```php
Laravel\Passport\PassportServiceProvider::class,
```

Passport 使用服务提供者注册内部的数据库迁移脚本目录，所以上一步完成后，你需要更新你的数据库结构。Passport 的迁移脚本会自动创建应用程序需要的客户端数据表和令牌数据表：

```sh
$ php artisan migrate
```

接下来，你需要运行 `passport:install `命令来创建生成安全访问令牌时用到的加密密钥，同时，这条命令也会创建「私人访问」客户端和「密码授权」客户端：

```sh
$ php artisan passport:install
```

上面命令执行后，请将` Laravel\Passport\HasApiTokens` Trait 添加到`App\User `模型中，这个 Trait 会给你的模型提供一些辅助函数，用于检查已认证用户的令牌和使用作用域：

```php
<?php

namespace App;

use Laravel\Passport\HasApiTokens;
use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;
}
```

接下来，需要在 `AuthServiceProvider `的 `boot` 方法中调用 `Passport::routes` 函数。这个函数会注册一些在访问令牌、客户端、私人访问令牌的发放和吊销过程中会用到的必要路由：

```php
<?php

namespace App\Providers;

use Laravel\Passport\Passport;
use Illuminate\Support\Facades\Gate;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array
     */
    protected $policies = [
        'App\Model' => 'App\Policies\ModelPolicy',
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Passport::routes();

        //令牌有效期
        Passport::tokensExpireIn(Carbon::now()->addDays(15));

        Passport::refreshTokensExpireIn(Carbon::now()->addDays(30));
    }
}
```

最后，需要将配置文件 `config/auth.php` 中 `api` 部分的授权保护项（ `driver` ）改为 `passport `。此调整会让你的应用程序在接收到 API 的授权请求时使用 Passport 的 `TokenGuard `来处理：

```php
'guards' => [
    'web' => [
        'driver' => 'session',
        'provider' => 'users',
    ],

    'api' => [
        'driver' => 'passport',
        'provider' => 'users',
    ],
],
```

### 创建认证方法

官方文档中针对如何简单使用做了初步介绍，下面我试着构造一个完整的客户端授权流程，首先创建`ApiController`：

```sh
$ php artisen make:controller Frontend/ApiController
```

在`ApiController`中引入`AuthenticatesUsers`模块，客户端需要通过密码授权的方式来认证，我们需要在`ApiController`中重写`AuthenticatesUsers`部分功能函数来实现整个完整的授权流程,在这里我们调用Passport提供的`oauth/token`接口：

```php
<?php

namespace App\Http\Controllers\Frontend;

use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class ApiController extends Controller
{
    use AuthenticatesUsers;

    public function __construct()
    {
//        $this->middleware('api');
    }

    //调用认证接口获取授权码
    protected function authenticateClient(Request $request)
    {
        $credentials = $this->credentials($request);

        $data = $request->all();

        $request->request->add([
            'grant_type' => $data['grant_type'],
            'client_id' => $data['client_id'],
            'client_secret' => $data['client_secret'],
            'username' => $credentials['email'],
            'password' => $credentials['password'],
            'scope' => ''
        ]);

        $proxy = Request::create(
            'oauth/token',
            'POST'
        );

        $response = \Route::dispatch($proxy);

        return $response;
    }

    //以下为重写部分
    protected function authenticated(Request $request)
    {
        return $this->authenticateClient($request);
    }

    protected function sendLoginResponse(Request $request)
    {
        $this->clearLoginAttempts($request);

        return $this->authenticated($request);
    }

    protected function sendFailedLoginResponse(Request $request)
    {
        $msg = $request['errors'];
        $code = $request['code'];
        return $this->returnJson($code, '', $msg);
    }
}

```

`User.php`模型中定义授权用户名

```php
public static function findFOrPassport($email)
    {
        return self::where('email', $email)->first();
    }
```

### 创建登录方法

```sh
$ php artisan make:controller Frontend/LoginController
```

```php
<?php
namespace App\Http\Controllers\Frontend;

use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;

class LoginController extends ApiController
{
    public function username()
    {
        return 'email';
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|exists:users',
            'password'  =>  'required|between:6,32',
        ]);

        if($validator->fails()) {
            $request->request->add([
                'errors'    =>  $validator->errors()->toArray(),
                'code'  =>  401,
            ]);
            return $this->sendFailedLoginResponse($request);
        }

        $credentials = $this->credentials($request);

        if($this->guard('api')->attempt($credentials, $request->has('remember'))) {
            return $this->sendLoginResponse($request);
        }

        return $this->returnJson(401, '', '登录失败');
}
```

### 创建路由

最后`routes/api.php`中加入我们需要的路由：

```php
//登录
Route::group(['prefix' => 'auth', 'namespace' => 'Frontend', 'middleware' => ['api']], function (){
    Route::post('login', 'LoginController@login');
});

//获取数据
Route::group(['prefix' => 'post', 'namespace' => 'Frontend', 'middleware' => 'auth:api'], function (){
    Route::get('getPosts', 'PostsController@index');
});
```

### 测试

postman 中调用接口

![file](http://7xlxn7.com1.z0.glb.clouddn.com/liH-FOri3LjAoTyu9YtXpqa8R28R.jpeg)

通过`access_token`获取数据
![file](http://7xlxn7.com1.z0.glb.clouddn.com/ltRGbC4d6eIF6BMj4Ud3yAzUNMc4.jpeg)
### 问题

错误1：
```
You must set the encryption key going forward to improve the security of this library - see this page for more information https://oauth2.thephpleague.com/v5-security-improvements/
```

解决：
修改`comporse.json` 文件

```json
"laravel/passport": "^3.0",` 
```

执行
```sh
$ comporse update
```
