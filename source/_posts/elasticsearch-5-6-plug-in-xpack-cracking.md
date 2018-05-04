---
title: elasticsearch-5.6插件x-pack破解
date: 2017-10-16 03:37:50
tags:
  - elasticsearch
  - x-pack
  - cracking
categories:
  - ELK
---


### 创建 `LicenseVerifier.java` 文件

```java
$ cat LicenseVerifier.java
package org.elasticsearch.license;

import java.nio.*;
import java.util.*;
import java.security.*;
import org.elasticsearch.common.xcontent.*;
import org.apache.lucene.util.*;
import org.elasticsearch.common.io.*;
import java.io.*;

public class LicenseVerifier
{
    public static boolean verifyLicense(final License license, final byte[] encryptedPublicKeyData) {
        return true;
    }

    public static boolean verifyLicense(final License license) {
        return true;
    }
}
```

<!--more -->

### 编译class文件

```sh
$ javac -cp "/usr/local/src/elasticsearch-5.6.0/lib/elasticsearch-5.6.0.jar:/usr/local/src/elasticsearch-5.6.0/lib/lucene-core-6.6.0.jar:/usr/local/src/elasticsearch-5.6.0/plugins/x-pack/x-pack-5.6.0.jar"  LicenseVerifier.java

$ ls License*
LicenseVerifier.class  LicenseVerifier.java

# 进入x-pack目录
$ cd /usr/local/src/elasticsearch-5.6.0/plugins/x-pack

$ mkdir test

$ mv x-pack-5.6.0.jar test/

# 备份文件
$ cp x-pack-5.6.0.jar /tmp

# 解压文件
$ jar xvf x-pack-5.6.0.jar

# 替换 class
$ cp /usr/local/src/LicenseVerifier.class org/elasticsearch/license

# 打包
$ jar cvf x-pack-5.6.0.jar .

# 打包好的文件放回x-pack目录下
$ cp x-pack-5.6.0.jar /usr/local/src/elasticsearch-5.6.0/plugins/x-pack/
```

### 申请license

[申请地址](https://license.elastic.co/registration)

申请完成后很快会发送到邮箱，而后修改license文件

它分有不同的版本，版本有不同的权限，如下：

1. open source开源版本
2. basic基础版本
3. gold是黄金版
4. PLATINUM铂金版

### 修改license

邮箱中有个链接，点击下载文件。

然后修改此文件

```json
{"license":{"uid":"5de7b3b82-66ffd0-1f8ee-92220dd5-f9c477aec563b6","type":"platinum","issue_date_in_millis":1506643200000,"expiry_date_in_millis":2535123399999,"max_nodes":100,"issued_to":"username (com)","issuer":"Web Form","signature":"AAAAAwAAAA3WtV1nOvU4U+frJxlhAAABmC9ZN0hjZDBGYnVyRXpCOW5Bb3FjZDAxOWpSbTVoMVZwUzRxVk1PSmkxaktJRVl5MUYvUWh3bHZVUTllbXNPbzBUemtnbWpBbmlWRmRZb25KNFlBR2x0TXc2K2p1Y1VtMG1UQU9TRGZVSGRwaEJGUjE3bXd3LzRqZ05iLzRteWFNekd24234xRGpIYlFwYkJiNUs0afea465U1hTVlJKNVlXekMrSlVUdFIvV0FNeWdOYnlESDc3MWhlY3hSQmdKSjJ2ZTcvYlBFOHhPQlV3ZHdDQ0tHcG5uOElCaDJ4K1hob29xSG85N0kvTWaefeV3THhlQk9NL01VMFRjNDZpZEdfaefaVXeUtUMXIyMlIveFpJUkk2WUdveEZaME9XWitGUi9WNTZVQW1FMG1DenhZU0ZmeXlZakVEMjZFT2NvOWxpZGlqVmlHNC8rWfaefVVUYzMwRGVySHpIdURzKzFiRDl4TmM1TUp2VTBOUlJZUlAyV0ZVL2kvVk10L0Ns1423bXNFYVZwT3NSU082dFNNa2pr2Q0ZsclZ4NTltbU1CVE5lR09Bck93V2J1Y3c9PQAAAQCj/qb1/6KaXgoLi4gzu5JgLz9M9TFvFnfXWih19ampCemtClX0nbiYc0JAdN/z0bqtbjQMulF7t92NSEtFFJ+9KvBM28cLhVEO0AvdLj/q0vAtXbl/mzFLxDt0ogPXIWhMJ4Fn0+5e8uAuWbziRZ3Q324r9vzCLp8IYnmUau3PmrpkL4YaVlPMbuYRnpZMOjS2hctxStqFWYEudvQj/QwMRwAhKpGJ0P8z24234ryrHEPcciskuAmGTpRsxVBUToBvgA4dSnlLrYzEjpCsXjj7HkVBj9yJ4CcIVVvcQ6bdFtI47i4L0zoea4lpuiCLlMGOrvUS/uE3mmlXQXAX1zt4mgtdmLOX","start_date_in_millis":1506643200000}}
```

最后更新

```sh
$ curl -XPUT -u elastic:changeme 'http://localhost:9200/_xpack/license' -H "Content-Type: application/json" -d @license.json
{"acknowledged":true,"license_status":"valid"}
```

查看修改后

```sh
$ curl -XGET -u elastic:changeme 'http://localhost:9200/_xpack/license'
{
  "license" : {
    "status" : "active",
    "uid" : "5de7b3b82-66ffd0-1f8ee-92220dd5-f9c477aec563b6",
    "type" : "platinum",
    "issue_date" : "2017-09-29T00:00:00.000Z",
    "issue_date_in_millis" : 1506643200000,
    "expiry_date" : "2050-05-02T16:56:39.999Z",
    "expiry_date_in_millis" : 2535123399999,
    "max_nodes" : 100,
    "issued_to" : "username (com)",
    "issuer" : "Web Form",
    "start_date_in_millis" : 1506643200000
  }
}
```

登录kinana查看

![file](http://7xlxn7.com1.z0.glb.clouddn.com/lu2-bJvqPaGXI4aF9NOhiqdoRSU6.jpeg)
