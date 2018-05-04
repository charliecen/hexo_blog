---
title: 密码错误3次锁定账号
date: 2017-03-03 05:23:11
tags:
  - password-verity
  - lock-user
  - three-times
categories:
  - PHP
  - Lumen
---

##### 逻辑简介
创建数据表

```sql
CREATE TABLE `userlock` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `userid` int(10) unsigned NOT NULL COMMENT '用户id',
  `lock_time` int(11) unsigned NOT NULL DEFAULT '14400' COMMENT '锁定时间，默认14400秒',
  `error_times` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '错误次数，默认0次',
  `last_login` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最新登录时间',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userid` (`userid`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
```

<!-- more -->
1. 判断用户是否在`userlock`表中；如果不存在，则继续验证登录密码；
2. 如果存在，则判断`userlock`中的当前时间`time()`减去`last_login`是否大于`lock_time`，如果大于，则继续验证密码；否则判断`error_times`是否大于等于3次，如果大于，返回`false`;
3. 回到第一步，验证密码，如果密码错误并且用户不存在`userlock`表中，则插入数据；`error_times`为1，`last_login`为当前时间；写入到`userlock`表中；
4. 如果用户已在`userlock`表中，则判断`time()`减去`last_login`是否大于`lock_time`,如果大于则`error_times`为1，否则`error_times`自加1, `last_login`为当前时间;写入到`userlock`表中；
5. 还是回到第一步，验证密码，如果密码正确，则判断该用户是否在`userlock`表中;如果存在，则`error_times`为0，`last_login`为当前时间，保存该表；

##### 代码逻辑
用户登录前,检测用户是否在锁表内

```php
public function checkLock($userid)
    {
        $userlock = new UserLock();
        $userlock_data = $userlock->where('userid', '=', $userid)->first();
        //用户不在锁表内
        if(!$userlock_data) return true;
        //用户在锁表内,并且锁定时间小于4小时,并且错误次数大于3;
        $validTime = time() - strtotime($userlock_data['last_login']);
        if($validTime < $userlock_data['lock_time']){
            if($userlock_data['error_times'] >= 3)
                return false;
        }
        return true;
    }
```

判断用户是否在`userlock`中

```php
public function insertlock($id)
    {
        $userlock = new UserLock();
        $userlock_data = UserLock::where("userid",$id)->first();
        if($userlock_data){
            $userlock = UserLock::find($userlock_data['id']);
            $userlock->userid = $id;
            //如果锁表的时间在4小时之内,则error_times + 1;否则为1;
            $validTime = time() - strtotime($userlock_data['last_login']);
            if($validTime < $userlock_data['lock_time']) {
                $userlock->error_times += 1;
            }else{
                $userlock->error_times = 1;
            }
            $userlock->last_login = date('Y-m-d H:i:m', time());
            if($userlock->save())
                return $userlock;
        }else{
            //如果用户不在锁表内,则新增;
            $userlock->userid = $id;
            $userlock->error_times = 1;
            $userlock->last_login = date('Y-m-d H:i:m', time());
            if($userlock->save())
                return $userlock;
        }
        return false;
    }
```

如果密码验证成功

```php
$userlock = $userlock->where('userid','=',$user_data['id'])->first();
if($userlock){
    $userlock->error_times = 0;
    $userlock->last_login = date('Y-m-d H:i:m', time());
    $userlock->save();
}
```

