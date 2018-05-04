---
title: lumen表单验证
date: 2017-03-03 05:15:54
tags: 
  - form-validate
  - validator
categories:
  - PHP
  - Lumen
comments: true
---

##### 简介
Lumen 提供了多种不同的处理方法来对应用程序传入的数据进行验证。默认情况下，Lumen 的基底控制器类使用了 ValidatesRequests trait，其提供了一种便利的方法来使用各种强大的验证规则验证传入的 HTTP 请求。

Lumen 和 Laravel 验证功能除了接下来会列出来的不同点以外，并没有太大区别，所以更多关于 Lumen 验证的使用，请参阅 Laravel 文档 。

> Lumen 与 Laravel 不同，表单请求验证需要Laravel支持。Lumen 可以使用`$this-validate`方法来验证。

> 还有不同的是，Lumen 支持路由闭包的方式直接使用`validate`方法
<!-- more -->

```php
use Illuminate\Http\Request;

$app->post('/user', function (Request $request) {
    $this->validate($request, [
        'name' => 'required',
        'email' => 'required|email|unique:users'
    ]);

    // 存储用户...
});
```

> 同样可以使用`Validator::make()` facade方法来验证

##### 添加验证规则
验证规则可以放在路由下，也可以放在`Controller`方法下；

```php
public function store(Request $request)
{
    $this->validate($request, [
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
    ]);

    // The blog post is valid, store in database...
}
```
如你所见，我们将本次 HTTP 请求及所需的验证规则传递至 validate 方法中。另外再提醒一次，如果验证失败，将会自动生成一个对应的响应。如果验证通过，那我们的控制器将会继续正常运行。

本人使用验证规则放在`Model`中的方法里

```php
 public function rules($array = ['username', 'email', 'password', 'mobile_no', 'old_password'])
    {
        $rules =  [
            'username' =>  'required|regex:/^[a-zA-Z][a-zA-Z0-9]{5,11}$/',
            'email' =>  'required|email',
            'password'  => 'required|min:6',
            'old_password'  => 'required|min:6',
            'mobile_no' => 'required|numeric|digits:11',
        ];
        foreach($array as $item){
            $data[$item] =  $rules[$item];
        }
        return $data;
    }
```
并且附上自定义错误信息

```php
public function message()
    {
        return  [
            'username.required' => '请填写用户名',
            'username.unique' => '用户名已存在',
            'username.regex' => '用户名不合法',
            'email.required' => '请填写邮箱地址',
            'email.unique'    =>  '邮箱名已存在',
            'email.email' =>  '邮箱名不合法',
            'password.required'    =>  '请填写密码',
            'password.min'  =>  '密码至少需要 :min 位字符',
            'mobile_no.required'    =>  '请填写手机号',
            'mobile_no.unique'  =>  '手机号已存在',
            'mobile_no.numeric' =>  '手机号必须为数字',
            'mobile_no.digits'  =>  '手机号必须为 :digits 位',
        ];
    }
```

##### 添加规则
在基础类里添加验证方法

```php
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;

public function ruleValidator(Request $request, $rule=[], $message=[])
    {
        $validator = Validator::make($request->all(), $rule, $message);

        if($validator->fails()){
            foreach($validator->errors()->getMessages() as $message){
                return $this->formatOutput(1, '', $message[0]);
            }
        }
        return null;
    }
```

具体操作则调用此方法，验证方式灵活

```php
$validator_user = $this->ruleValidator($request, $user->rules(['username','password']), $user->message());
            if ($validator_user)
                return $validator_user;
```


参考文档:
<https://lumen.laravel-china.org/docs/5.3/validation>
<https://www.kancloud.cn/iwzh/laravel-doc5_3/229847>

