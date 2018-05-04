---
title: lumen 头像上传
date: 2017-03-06 05:50:17
tags:
  - uploadFile
  - avatar
categories:
  - PHP
  - Lumen
comments: true
---

##### 简介

`Lumen` 可以使用 `Illuminate\Http\Request` 实例中的 `file` 方法来获取上传文件。`file`方法返回的对象是 `Symfony\Component\HttpFoundation\File\UploadedFile` 类的实例，该类继承了 PHP 的 `SplFileInfo` 类，并提供了许多和文件交互的方法：<br>

```php
$file = $request->file('photo');
```

你可以使用请求的 `hasFile` 方法确认上传的文件是否存在：<br>
<!-- more -->

```php
if ($request->hasFile('photo')) {
    //
}
```

除了检查上传的文件是否存在外，你也可以通过 `isValid` 方法验证上传的文件是否有效<br>

```php
if ($request->file('photo')->isValid()) {
    //
}
```
移动上传的文件
若要移动上传的文件至新位置，则必须使用 `move` 方法。该方法会将文件从缓存位置（由你的 PHP 配置决定）移动至你指定的永久保存位置：

```php
$request->file('photo')->move($destinationPath);

$request->file('photo')->move($destinationPath, $fileName);
```

##### 代码如下
创建保存文件的目录

```php
protected function mk_dir($path)
    {
        $dir = date('y/md', time());
        if(is_dir($path . '/' . $dir)){
            return $path . '/' . $dir;
        }else{
            mkdir($path . '/' . $dir,0777,true);
            return $path . '/' . $dir;
        }
    }
```
上传文件

```php
public function uploadAvatar(Request $request)
    {
        $id = Auth::user()->id;
        //获取文件
        $avatar = $request->file('avatar');
        //判断文件是否有效
        if(!($request->hasFile('avatar') && $avatar->isValid()))
            return $this->formatOutput(1, '', '没有图片');
        //表单验证
        $userinfo = new Userinfo();
        $validator_userinfo = $this->ruleValidator($request, $userinfo->rules(['avatar']), $userinfo->message());
        if($validator_userinfo)
            return $validator_userinfo;
        //获取文件后缀
        $ext = $avatar->getClientMimeType();
        $ext = explode('/',$ext);
        //获取文件大小
        $img_size = floor($avatar->getSize() / 1024) . 'KB';
        if($img_size >= 2048){
            return $this->formatOutput(1, '', '文件大小不能超过2MB');
        }
        //存储图片
        $request->file('avatar')->move($this->mk_dir($this->path), '/' . $avatar->getFilename() . '.' . $ext[1]);
        $src_img_path = $this->mk_dir($this->path) . '/' . $avatar->getFilename() . '.' . $ext[1];
        $des_img_path = $this->mk_dir($this->small_path) . '/' . 'small_' . $avatar->getFilename() . '.' . $ext[1];
        //生成缩略图
        $slt = $this->CreateImage($src_img_path, $des_img_path, 40,40);
        if($slt){
            //保存到数据库
            $res = DB::update('update userinfo set avatar ="'. $des_img_path . '" where userid = '.$id);
            if($res){
                $data['avatar'] = $des_img_path;
                return $this->formatOutput(0, $data, '文件上传成功');
            }else{
                return $this->formatOutput(1, '', '文件上传失败');
            }
        }else{
            return $this->formatOutput(1, '', '生成缩略图失败');
        }
    }
```

生成缩略图代码

```php
protected  function CreateImage($SrcImageUrl, $DirImageUrl, $Width, $Height)
    {
        // 图片类型
        $type = substr(strrchr($SrcImageUrl, "."), 1);

        // 初始化图像
        if ($type == "jpg")
            $img = imagecreatefromjpeg($SrcImageUrl);
        if ($type == "gif")
            $img = imagecreatefromgif($SrcImageUrl);
        if ($type == "png")
            $img = imagecreatefrompng($SrcImageUrl);

        $srcw = imagesx($img);
        $srch = imagesy($img);

        if ($srcw / $srch > $Width / $Height) {
            if ($srcw > $Width) {
                $new_width = $Width;
                $new_height = $srch * ($Width / $srcw);
            } else {
                $new_width = $srcw;
                $new_height = $srch;
            }
        } else {
            if ($srch > $Height) {
                $new_height = $Height;
                $new_width = $srcw * ($Height / $srch);
            } else {
                $new_width = $srcw;
                $new_height = $srch;
            }
        }

        $new_image = imagecreatetruecolor($new_width, $new_height);
        imagecopyresampled($new_image, $img, 0, 0, 0, 0, $new_width, $new_height, $srcw, $srch);
        imagejpeg($new_image, $DirImageUrl);

        imagedestroy($img);
        imagedestroy($new_image);
        return true;
    }
```

##### 测试
返回结果

```javascript
{
  "code": 0,
  "data": {
    "avatar": "small_avatar/17/0302/small_phpXkcJAT.png"
  },
  "msg": "文件上传成功"
}
```
