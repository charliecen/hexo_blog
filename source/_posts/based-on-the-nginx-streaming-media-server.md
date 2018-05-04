---
title: 基于nginx流媒体服务器搭建
tags:
  - ffmpeg
  - mencoder
  - nginx
  - x.264
id: 560
categories:
  - Linux
  - Nginx
date: 2015-09-21 09:50:00
---

<div>七牛云存储的流媒体服务，我申请了个测试帐号，在内容管理上传你的视频文件，生成外链。</div>
<div>到自己博客里把外链添加到文章里。貌似不能播放。应该是视频格式或者编码问题，问过他们技术，需要转码。但是MPS服务还要认证。然后自己在本地搭建个流媒体服务器。</div>
<!-- more -->
<div>流媒体播放方式：</div>
<div>HTTP方式</div>
<div>这种方式要下载FLV视频文件到本地播放，一旦FLV视频文件下载完成，就不会消耗服务器的资源和带宽，但是拖动功能没有RTMP/RTMP流媒体方式强大，很多视频网站都是用HTTP方式实现的，如：YouTube，土豆，酷6等</div>
<div></div>
</div>
<div>RTMP/RTMP流媒体方式</div>
<div>这种方式不用下载FLV视频文件到本地，可以实时的播放flv文件，可以任意拖拽播放进度条，但是比较消耗服务器的资源。</div>
</div>
<div></div>
<div></div>
<div>
<div>系统：centos6.5</div>
<div>软件：nginx-1.8</div>

### 1.由于安装时很多依赖包，需要添加源

<pre class="lang:sh decode:true ">[root@VM-242 src]# cd /usr/local/src
[root@VM-242 src]# wget -c http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
[root@VM-242 src]# rpm –import http://apt.sw.be/RPM-GPG-KEY.dag.txt
[root@VM-242 src]# rpm -i rpmforge-release-0.5.3-1.el6.rf.*.rpm</pre>

### 2.安装转码工具Mencoder和ffmpeg

#### 2.1 安装依赖库

<pre class="lang:sh decode:true ">[root@VM-242 src]# yum install gcc make automake bzip2 unzip patch subversion libjpeg-devel</pre>

#### 2.2 安装yasm

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
[root@VM-242 src]# tar zxvf yasm-1.2.0.tar.gz
[root@VM-242 src]# cd yasm-1.2.0
[root@VM-242 yasm-1.2.0]# ./configure
[root@VM-242 yasm-1.2.0]# make &amp;&amp; make install
[root@VM-242 yasm-1.2.0]# cd ..</pre>

#### 2.3 卸载系统原有的ffmpeg和x264

<pre class="lang:sh decode:true ">[root@VM-242 src]# yum remove ffmpeg x264</pre>

#### 2.4 安装Mplayer编码库

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget -c http://www2.mplayerhq.hu/MPlayer/releases/codecs/essential-amd64-20071007.tar.bz2
[root@VM-242 src]# tar xf essential-amd64-20071007.tar.bz2
[root@VM-242 src]# mkdir /usr/local/lib/codecs
[root@VM-242 src]# cp -Rvp essential-amd64-20071007/* /usr/local/bin/codecs/

[root@VM-242 src]# vim /etc/ld.so.conf
/usr/lib
/usr/local/lib</pre>

#### 2.5 加载动态库

<pre class="lang:sh decode:true ">[root@VM-242 src]# ldconfig</pre>

#### 2.6 安装一些格式转换常用的编码库

<pre class="lang:sh decode:true ">[root@VM-242 src]# yum install faac-devel  lame-devel amrnb-devel opencore-amr-devel amrwb-devel  libvorbis-devel libtheora-devel xvidcore-devel</pre>

#### 2.7 安装x.264

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget ftp://ftp.videolan.org/pub/videolan/x264/snapshots/last_stable_x264.tar.bz2
[root@VM-242 src]# tar xvjf last_stable_x264.tar.bz2
[root@VM-242 src]# cd x264-snapshot-20150920-2245-stable/
[root@VM-242 x264-snapshot-20150920-2245-stable]# ./configure –enable-shared –enable-pic
[root@VM-242 x264-snapshot-20150920-2245-stable]# make &amp;&amp; make install
[root@VM-242 x264-snapshot-20150920-2245-stable]# cd ..</pre>

#### 2.8 安装libvpx

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget http://webm.googlecode.com/files/libvpx-v1.2.0.tar.bz2
[root@VM-242 src]# tar xf libvpx-v1.2.0.tar.bz2
[root@VM-242 src]# cd libvpx-v1.2.0
[root@VM-242 libvpx-v1.2.0]# ./configure --enable-shared --enable-pic
[root@VM-242 libvpx-v1.2.0]# make &amp;&amp; make install
[root@VM-242 libvpx-v1.2.0]# cd ..</pre>

#### 2.9 安装ffmpeg

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget http://ffmpeg.org/releases/ffmpeg-2.0.1.tar.bz2
[root@VM-242 src]# tar xf ffmpeg-2.0.1.tar.bz2
[root@VM-242 src]# cd ffmpeg-2.0.1
[root@VM-242 ffmpeg-2.0.1]# ./configure --enable-gpl --enable-version3 --enable-shared --enable-nonfree --enable-postproc --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libop --encore-amrwb --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libxvid
[root@VM-242 ffmpeg-2.0.1]# make &amp;&amp; make install
[root@VM-242 ffmpeg-2.0.1]# cd ..</pre>

#### 2.10 安装mencoder

<pre class="lang:sh decode:true ">[root@VM-242 src]# yum install mplayer mencoder flvtool2</pre>

#### 2.11 查看已经安装好的视频和视频编码器

<pre class="lang:sh decode:true ">查看支持的音频编码
[root@VM-242 src]# mencoder -oac help
查看支持的视频编码
[root@VM-242 src]# mencoder -ovc help
可参考：http://www.mplayerhq.hu/DOCS/HTML/zh_CN/menc-feat-selecting-codec.html</pre>

### 3.安装nginx

#### 3.1首先安装依赖库pcre

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget http://sourceforge.net/projects/pcre/files/pcre/8.37/pcre-8.37.tar.gz
[root@VM-242 src]# tar xf pcre-8.37.tar.gz</pre>

#### 3.2 安装yamdi用来为flv创建关键帧才能随意拖动

<pre class="lang:sh decode:true">[root@VM-242 src]# yum install gcc gcc-c++ openssl-devel zlib-devel yamdi</pre>

#### 3.3 下载所需的nginx模块

##### 3.3.1 第一个是nginx_mod_h264_streaming,让nginx支持flv/mp4流播放

</div>
<pre class="lang:sh decode:true ">[root@VM-242 src]# wget http://h264.code-shop.com/download/nginx_mod_h264_streaming-2.2.7.tar.gz
[root@VM-242 src]# tar xf nginx_mod_h264_streaming-2.2.7.tar.gz

注意：先要修改一下这家伙的源码，注释掉nginx_mod_h264_streaming-2.2.7/src/ngx_http_streaming_module.c的158到161行
     /* TODO: Win32 */
     //if (r-&gt;zero_in_uri)
     // {
     //   return NGX_DECLINED;
     // }</pre>

##### 3.3.2 第二个是nginx-rtmp-module，让nginx支持rtmp/hls协议

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget -O nginx-rtmp-module.zip  https://github.com/arut/nginx-rtmp-module/archive/master.zip
[root@VM-242 src]# unzip nginx-rtmp-module.zip</pre>

##### 3.3.3 下载清缓存的模块

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget -O ngx_cache_purge.zip https://github.com/FRiCKLE/ngx_cache_purge/archive/master.zip
[root@VM-242 src]# unzip ngx_cache_purge.zip</pre>

#### 3.4 下载nginx

<pre class="lang:sh decode:true ">[root@VM-242 src]# wget http://nginx.org/download/nginx-1.8.0.tar.gz
[root@VM-242 src]# tar xf nginx-1.8.0.tar.gz
[root@VM-242 src]# cd nginx-1.8.0
[root@VM-242 nginx-1.8.0]# ./configure --user=daemon --group=daemon --prefix=/usr/local/nginx/ --add-module=../nginx-rtmp-module-master --add-module=../ngx_cache_purge-master --add-module=../nginx_mod_h264_streaming-2.2.7 --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-http_gzip_static_module --with-http_flv_module --with-pcre=../pcre-8.37
[root@VM-242 nginx-1.8.0]# make &amp;&amp; make install
[root@VM-242 nginx-1.8.0]# cd ..</pre>

#### 3.5 运行nginx

<pre class="lang:sh decode:true ">[root@VM-242 src]# /urs/local/nginx/sbin/nginx</pre>

#### 3.6 nginx添加到环境变量

<pre class="lang:sh decode:true ">[root@VM-242 src]# vim /root/.bash_profile
PATH=$PATH:$HOME/bin:/usr/local/nginx/sbin

[root@VM-242 src]# source /root/.bash_profile</pre>

#### 3.7 编辑配置文件

<pre class="lang:sh decode:true">[root@VM-242 src]# egrep -v '^$|^#|#' /usr/local/nginx/conf/nginx.conf
user daemon daemon;
worker_processes  1;
events {
    worker_connections  1024;
}
rtmp {
    server {
    listen 1935;
    chunk_size 4000;
    application vod {
        play /mnt/media/vod;
    }
    application hls {
            hls on;
            hls_path /mnt/media/app;
            hls_fragment 10s;
    }
    }
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    server {
        listen       8080;
        server_name  localhost;
        location / {
        root /mnt/soft/nginx-rtmp-module-master/test/rtmp-publisher;
        }
    location /stat {
        rtmp_stat all;
        rtmp_stat_stylesheet stat.xsl;
    }
    location /stat.xsl {
        root /mnt/soft/nginx-rtmp-module-master;
    }
    location /control {
        rtmp_control all;

    }
}
    server {
    listen        80;
    server_name     localhost;
    location / {
        root /mnt/wwwroot;
        index index.html;
    }
    location ~ \.flv$ {
        root /mnt/media/vod;
        flv;
        limit_conn addr 20;
        limit_rate 200k;
    }
    location ~ \.mp4$ {
        root /mnt/media/vod;
        mp4;
        limit_conn addr 20;
        limit_rate 200k;
    }
    location /hls {
        alias /mnt/media/app;
    }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}

重新加载配置文件
[root@VM-242 src]# nginx -t
[root@VM-242 src]# nginx -s reload</pre>

#### 3.8 测试

#### 

<div>上传个mp4文件到/mnt/media/vod</div>
<div>打开浏览器播放</div>
<div>http://10.19.21.241/love.mp4</div>
![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150921-3@2x.jpg)
<div>/mnt/media/video -&gt; 存放原始视频</div>
<div>/mnt/media/app  -&gt; 存放转成m3u8的视频,供http访问(HLS)</div>
<div>/mnt/media/vod  -&gt; 存放转换后的flv和mp4视频,供http或rtmp访问</div>
<div></div>

#### 3.9 网上下载了个avi格式的视频，需要转换成mp4格式才能播放

使用ffmpeg工具来转换
<pre class="lang:sh decode:true ">[root@VM-242 src]# cd /mnt/media/video
[root@VM-242 video]# ffmpeg -i test.avi -f mp4 -acodec libfaac -vcodec libx264 -b 512k -ab 320k ../vod/test1.mp4
ffmpeg version 2.0.1 Copyright (c) 2000-2013 the FFmpeg developers
  built on Sep 21 2015 14:01:20 with gcc 4.4.7 (GCC) 20120313 (Red Hat 4.4.7-16)
  configuration: --enable-gpl --enable-version3 --enable-shared --enable-nonfree --enable-postproc --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libxvid
  libavutil      52\. 38.100 / 52\. 38.100
  libavcodec     55\. 18.102 / 55\. 18.102
  libavformat    55\. 12.100 / 55\. 12.100
  libavdevice    55\.  3.100 / 55\.  3.100
  libavfilter     3\. 79.101 /  3\. 79.101
  libswscale      2\.  3.100 /  2\.  3.100
  libswresample   0\. 17.102 /  0\. 17.102
  libpostproc    52\.  3.100 / 52\.  3.100
Input #0, avi, from 'test.avi':
  Metadata:
    encoder         : MEncoder SVN-r33883(20110719-gcc4.5.2)
  Duration: 00:03:49.54, start: 0.000000, bitrate: 1676 kb/s
    Stream #0:0: Video: mpeg4 (Advanced Simple Profile) (XVID / 0x44495658), yuv420p, 640x360 [SAR 1:1 DAR 16:9], 24 tbr, 24 tbn, 24 tbc
    Stream #0:1: Audio: mp3 (U[0][0][0] / 0x0055), 44100 Hz, stereo, s16p, 224 kb/s
Please use -b:a or -b:v, -b is ambiguous
[libx264 @ 0xb6bf00] using SAR=1/1
[libx264 @ 0xb6bf00] using cpu capabilities: MMX2 SSE2Fast SSSE3 SSE4.2
[libx264 @ 0xb6bf00] profile High, level 3.0
[libx264 @ 0xb6bf00] 264 - core 146 - H.264/MPEG-4 AVC codec - Copyleft 2003-2015 - http://www.videolan.org/x264.html - options: cabac=1 ref=3 deblock=1:0:0 analyse=0x3:0x113 me=hex subme=7 psy=1 psy_rd=1.00:0.00 mixed_ref=1 me_range=16 chroma_me=1 trellis=1 8x8dct=1 cqm=0 deadzone=21,11 fast_pskip=1 chroma_qp_offset=-2 threads=3 lookahead_threads=1 sliced_threads=0 nr=0 decimate=1 interlaced=0 bluray_compat=0 constrained_intra=0 bframes=3 b_pyramid=2 b_adapt=1 b_bias=0 direct=1 weightb=1 open_gop=0 weightp=2 keyint=250 keyint_min=24 scenecut=40 intra_refresh=0 rc_lookahead=40 rc=abr mbtree=1 bitrate=512 ratetol=1.0 qcomp=0.60 qpmin=0 qpmax=69 qpstep=4 ip_ratio=1.40 aq=1:1.00
Output #0, mp4, to '../vod/test1.mp4':
  Metadata:
    encoder         : Lavf55.12.100
    Stream #0:0: Video: h264 (libx264) ([33][0][0][0] / 0x0021), yuv420p, 640x360 [SAR 1:1 DAR 16:9], q=-1--1, 512 kb/s, 12288 tbn, 24 tbc
    Stream #0:1: Audio: aac (libfaac) ([64][0][0][0] / 0x0040), 44100 Hz, stereo, s16, 320 kb/s
Stream mapping:
  Stream #0:0 -&gt; #0:0 (mpeg4 -&gt; libx264)
  Stream #0:1 -&gt; #0:1 (mp3 -&gt; libfaac)
Press [q] to stop, [?] for help
frame= 5510 fps= 67 q=-1.0 Lsize=   18091kB time=00:03:49.59 bitrate= 645.5kbits/s dup=1 drop=0
video:13693kB audio:4226kB subtitle:0 global headers:0kB muxing overhead 0.963257%
[libx264 @ 0xb6bf00] frame I:30    Avg QP:20.08  size: 23465
[libx264 @ 0xb6bf00] frame P:2541  Avg QP:24.65  size:  4498
[libx264 @ 0xb6bf00] frame B:2939  Avg QP:31.54  size:   642
[libx264 @ 0xb6bf00] consecutive B-frames: 10.5% 45.3% 29.5% 14.7%
[libx264 @ 0xb6bf00] mb I  I16..4: 16.0% 60.6% 23.4%
[libx264 @ 0xb6bf00] mb P  I16..4:  1.3%  5.0%  0.9%  P16..4: 31.9% 12.6%  7.8%  0.0%  0.0%    skip:40.5%
[libx264 @ 0xb6bf00] mb B  I16..4:  0.1%  0.3%  0.0%  B16..8: 25.7%  2.2%  0.5%  direct: 1.0%  skip:70.2%  L0:34.1% L1:54.8% BI:11.2%
[libx264 @ 0xb6bf00] final ratefactor: 23.57
[libx264 @ 0xb6bf00] 8x8 transform intra:68.0% inter:67.4%
[libx264 @ 0xb6bf00] coded y,uvDC,uvAC intra: 55.4% 42.0% 7.5% inter: 10.8% 5.6% 0.3%
[libx264 @ 0xb6bf00] i16 v,h,dc,p: 25% 44% 10% 21%
[libx264 @ 0xb6bf00] i8 v,h,dc,ddl,ddr,vr,hd,vl,hu: 27% 26% 24%  3%  4%  5%  3%  4%  5%
[libx264 @ 0xb6bf00] i4 v,h,dc,ddl,ddr,vr,hd,vl,hu: 25% 27% 12%  5%  7%  8%  6%  6%  5%
[libx264 @ 0xb6bf00] i8c dc,h,v,p: 54% 24% 19%  3%
[libx264 @ 0xb6bf00] Weighted P-Frames: Y:4.3% UV:1.7%
[libx264 @ 0xb6bf00] ref P L0: 66.0% 16.3% 13.5%  4.1%  0.0%
[libx264 @ 0xb6bf00] ref B L0: 86.7% 12.4%  0.9%
[libx264 @ 0xb6bf00] ref B L1: 95.3%  4.7%
[libx264 @ 0xb6bf00] kb/s:488.57</pre>
<div>参数详解</div>
<div>-i 指定输入文件</div>
<div>-f 输出格式</div>
<div>-acodec 指定声音编码器</div>
<div>-vcodec 指定视频编码器</div>
<div>-b 指定视频流量</div>
<div>-ab 指定声音流量</div>
<div></div>
<div>
<div>

FFmpeg可使用众多参数，参数内容会根据ffmpeg版本而有差异，使用前建议先参考参数及编解码器的叙述。此外，参数明细可用 ffmpeg -h 显示；编解码器名称等明细可用 ffmpeg -formats 显示。

</div>
<div>
<div>
<div>下列为较常使用的参数。</div>
<div>**主要参数**</div>
</div>
</div>
<div>

-i 设定输入档名。
-f 设定输出格式。
-y 若输出档案已存在时则覆盖档案。
-fs 超过指定的档案大小时则结束转换。
-ss 从指定时间开始转换。
-title 设定标题。
-timestamp 设定时间戳。
-vsync 增减Frame使影音同步。

</div>
<div>**影像参数**</div>
<div></div>
<div>
<div>-b 设定影像流量，默认为200Kbit/秒。（ 单位请参照下方注意事项 ）
-r 设定FrameRate值，默认为25。
-s 设定画面的宽与高。
-aspect 设定画面的比例。
-vn 不处理影像，于仅针对声音做处理时使用。
<div>-vcodec 设定影像影像编解码器，未设定时则使用与输入档案相同之编解码器。</div>
</div>
</div>
<div>** **</div>
<div>**声音参数**</div>
<div>

-ab 设定每Channel （最近的SVN 版为所有Channel的总合）的流量。（ 单位 请参照下方注意事项 ）
-ar 设定采样率。
-ac 设定声音的Channel数。
-acodec 设定声音编解码器，未设定时与影像相同，使用与输入档案相同之编解码器。
-an 不处理声音，于仅针对影像做处理时使用。
-vol 设定音量大小，256为标准音量。(要设定成两倍音量时则输入512，依此类推。)

</div>
<div></div>
<div>**注意事项**</div>
<div>

以-b及ab参数设定流量时，根据使用的ffmpeg版本，须注意单位会有kbits/sec与bits/sec的不同。（可用ffmpeg -h显示说明来确认单位。）

</div>
<div></div>
<div>
<div>
<div>例如，单位为bits/sec的情况时，欲指定流量64kbps时需输入‘ -ab 64k ’；单位为kbits/sec的情况时则需输入‘ -ab 64 ’。</div>
<div></div>
</div>
</div>
<div>
<div>
<div>以-acodec及-vcodec所指定的编解码器名称，会根据使用的ffmpeg版本而有所不同。例如使用AAC编解码器时，会有输入aac 与 libfaac的情况。此外，编解码器有分为仅供解码时使用与仅供编码时使用，因此一定要利用ffmpeg -formats 确 认输入的编解码器是否能运作。</div>
</div>
<div></div>
</div>
</div>
<div>转换后视频播放</div>
<div>http://10.19.21.241/test1.mp4</div>
![](http://blog.cenhq.com/wp-content/uploads/2015/09/QQ20150921-4@2x.jpg)
