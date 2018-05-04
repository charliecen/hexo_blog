---
title: Laravel 5.4 事件操作
date: 2017-03-22 05:18:14
tags:
  - Events
  - Listeners
  - EventServiceProvider
categories:
  - Laravel
---

### 简介
Laravel 事件机制实现了一个简单的观察者模式，让我们可以订阅和监听应用中出现的各种事件。事件类 (Event) 类通常保存在 `app/Events` 目录下，而它们的监听类 (Listener) 类被保存在 `app/Listeners` 目录下。如果你在应用中看不到这些文件夹也不要担心，因为当你使用 Artisan 命令来生成事件和监听器时他们会被自动创建。

事件机制是一种很好的应用解耦方式，因为一个事件可以拥有多个互不依赖的监听器。例如，这里我们基于之前基于模型+缓存对文章增删改查这篇文件对文章保存后缓存的处理做进一步优化。我们将文章保存（新建/修改）视为一个事件，将保存文章内容到缓存放到监听器中实现：
<!-- more -->
### 注册事件与监听器
Laravel 应用中的 `EventServiceProvider` 提供了一个很方便的地方来注册所有的事件监听器。它的 `listen` 属性是一个数组，包含所有的事件（键）以及事件对应的监听器（值）。你也可以根据应用需求来增加事件到这个数组中。例如，增加一个 PostSaved 事件：

```php
/**
 * 应用程序的事件监听器映射。
 *
 * @var array
 */
protected $listen = [
    'App\Events\PostSaved'  =>  [
        'App\Listeners\PostSavedToCache',
    ],
];
```

#### 生成事件和监听器
当然，手动创建每个事件和监听器是很麻烦的。简单的方式是，在 `EventServiceProvider` 类中添加好事件和监听器，然后使用 `event:generate` 命令。这个命令会自动生成 `EventServiceProvider` 类中列出的所有事件和监听器。当然已经存在的事件和监听器将保持不变。我们在项目根目录运行如下Artisan命令：

```sh
$ php artisan event:generate
```
该命令会在  `app/Events` 目录下生成 `PostSaved.php`，在`app/Listeners` 目录下生成 `SaveDataToCache.php`。

#### 手动注册事件
一般来说，事件必须通过 `EventServiceProvider` 类的 `$listen` 数组进行注册；不过，你也可以在 `EventServiceProvider` 类的 `boot` 方法中注册闭包事件。

```php
/**
 * 注册应用程序中的任何其他事件。
 *
 * @return void
 */
public function boot()
{
    parent::boot();
    
    //name可以使用通配符'*',它让你在一个监听器中可以监听到多个事件。通配符监听器接受的第一个参数是事件名称，第二个参数是整个的事件数据：
    Event::listen('event.name', function ($foo, $bar)   {
        //
    });
}
```

### 定义事件
事件类就是一个包含与事件相关信息数据的容器。接下来我们编辑事件类PostSaved如下：

```php
<?php
namespace App\Events;

use App\Model\Post;
use Illuminate\Broadcasting\Channel;
use Illuminate\Queue\SerializesModels;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Support\Facades\Event;

class PostSaved extends Event
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * Create a new event instance.
     *
     * @return void
     */
    public function __construct(Post $post)
    {
        $this->post = $post;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return Channel|array
     */
    public function broadcastOn()
    {
//        return new PrivateChannel('channel-name');
        return [];
    }
}
```
正如你所见，这个事件类中没有包含其它逻辑。它仅只是一个被构建的 `Post` 对象的容器。如果使用 PHP 的 `serialize` 函数对事件进行序列化，使用了 `SerializesModels` trait 的事件将会优雅的序列化任何的 `Eloquent` 模型。

### 定义监听器
接下来，让我们看一下例子中事件的监听器。事件监听器在 `handle` 方法中接受了事件实例作为参数。 `event:generate` 命令将会在事件的 `handle` 方法中自动加载正确的事件类和类型提示。在 `handle` 方法中，你可以运行任何需要响应该事件的业务逻辑。

```php
<?php

namespace App\Listeners;

use App\Events\PostSaved;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class PostSavedToCache
{
    /**
     * Create the event listener.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    /**
     * Handle the event.
     *
     * @param  PostSaved  $event
     * @return void
     */
    public function handle(PostSaved $event)
    {
        $post = $event->post;
        $key = 'post_'.$post->id;
        Cache::put($key,$post,60*24*7);
        Log::info('保存文章到缓存文件', ['id' => $post->id, 'title' => $post->title]);
    }
}
```

#### 停止事件传播
有时，你可能希望停止一个事件传播到其他的监听器。这时你可以通过在监听器的 `handle` 方法中返回 `false` 来实现。

### 触发事件
最后我们来测试文章保存事件及其监听器。

要触发文章保存事件，可以使用`Event`门面提供的`fire`方法，在`PostController`中修改`add`方法如下：

```php
public function add(Request $request)
{
    $post = new Post();
    $post->title = $request->input('title');
    $post->content = $request->input('content');
    if($post->save()){
        event(new PostSaved($post));
    }
    return redirect('post');
}
```

访问浏览器添加文章，添加后查看日志`storage/logs/laravel.log`

```php
[2017-03-22 03:27:25] local.INFO: 保存文章到缓存文件 {"id":115,"title":"标题1"} 
```

说明已触发文章保存事件，监听器监听到事件后将其保存到缓存中并记录日志。
