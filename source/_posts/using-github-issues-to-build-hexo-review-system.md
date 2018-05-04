---
title: 使用 GitHub Issues 搭建 hexo 评论系统
date: 2017-07-25 03:00:41
tags:
  - Gitment
  - comment
categories:
  - Hexo
---

### 简介

`Gitment` 是作者实现的一款基于 GitHub Issues 的评论系统。支持在前端直接引入，不需要任何后端代码。可以在页面进行登录、查看、评论、点赞等操作，同时有完整的 Markdown / GFM 和代码高亮支持。尤为适合各种基于 GitHub Pages 的静态博客或项目页面。

本博客评论系统已迁移至 Gitment。虽然 Gitment 只能使用 GitHub 账号进行评论，但考虑到博客受众，这是可以接受的。

<!-- more -->

* [项目地址](#https://github.com/imsun/gitment)
* [示例页面](#https://imsun.github.io/gitment/)

### 使用

#### 安装Gitment

```sh
$ npm install --save gitment
```

#### 注册OAuth Application

[点击此处](#https://github.com/settings/applications/new) 来注册一个新的 `OAuth Application`。其他内容可以随意填写，但要确保填入正确的 `callback URL`（一般是评论页面对应的域名，如 http://www.cenhq.com）。

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lufytVWddvvXAvXLrC9JksD8cjIB.jpeg)

你会得到一个 `client ID` 和一个 `client secret`，这个将被用于之后的用户登录。

#### 引入Gitment

将下面的代码添加到你的页面：
> 我使用的主题是hexo，插入的文件是`themes/next/layout/_partials/comments.swig`

```javascript
<div id="container"></div>
<link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
<script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
<script>
var gitment = new Gitment({
  id: '页面 ID', // 可选。默认为 location.href
  owner: '你的 GitHub ID',
  repo: '存储评论的 repo',
  oauth: {
    client_id: '你的 client ID',
    client_secret: '你的 client secret',
  },
})
gitment.render('container')
</script>
```

#### 初始化评论

页面发布后，你需要访问页面并使用你的 `GitHub` 账号登录（请确保你的账号是第二步所填 `repo` 的 `owner`），点击初始化按钮。
之后其他用户即可在该页面发表评论。

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lruREySo573TKL3_Vz93Cm1G0Wqg.jpeg)

测试后可在github issues中可见评论内容

![file](http://7xlxn7.com1.z0.glb.clouddn.com/llkAeZwsO9_6mvk2xzv9T0FGp-Zq.jpeg)

### 自定义主题

Gitment 很容易进行自定义，你可以写一份自定义的 CSS 或者使用一个新的主题。（主题可以改变 DOM 结构而自定义 CSS 不能）

比如你可以通过自定义主题将评论框放在评论列表前面：

```javascript
const myTheme = {
  render(state, instance) {
    const container = document.createElement('div')
    container.lang = "en-US"
    container.className = 'gitment-container gitment-root-container'
    container.appendChild(instance.renderHeader(state, instance))
    container.appendChild(instance.renderEditor(state, instance))
    container.appendChild(instance.renderComments(state, instance))
    container.appendChild(instance.renderFooter(state, instance))
    return container
  },
}
const gitment = new Gitment({
  // ...
  theme: myTheme,
})
gitment.render('container')
```
