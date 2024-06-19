# 项目介绍

此项目是Fork [clash-for-linux](https://github.com/wanhebin/clash-for-linux)后针对AutoDL平台的一些简单适配

主要是为了解决我们在AutoDL平台服务器上下载GitHub等一些国外资源速度慢的问题。

> **注意：** 考虑到使用本仓库中的部分同学可能是这方面的新手，以下说明中添加了一些常见问题的解答和演示图片，请仔细阅读。如果图片看不清楚，可以安装[Imaugs](https://chromewebstore.google.com/detail/imagus/immpkjjlgappgfkkfieppnmlhakdmaab)，这是个老牌的Chrome插件，可以将图片放大查看。

<br>

# 使用须知

- 使用过程中如遇到问题，请优先查已有的 [issues](https://github.com/VocabVictor/clash-forAutoDL/issues)。
- 在进行issues提交前，请替换提交内容中是敏感信息（例如：订阅地址）。
- 本项目是基于 [clash](https://github.com/Dreamacro/clash) 、[yacd](https://github.com/haishanh/yacd) 进行的配置整合，关于clash、yacd的详细配置请去原项目查看。
- 此项目不提供任何订阅信息，请自行准备Clash订阅地址。
- 运行前请手动更改`.env`文件中的`CLASH_URL`变量值，否则无法正常运行。
- 当前在RHEL系列和Debian系列Linux系统中测试过，其他系列可能需要适当修改脚本。
- 支持 x86_64/aarch64 平台

> **注意**：当你在使用此项目时，遇到任何无法独自解决的问题请优先前往 [issues](https://github.com/VocabVictor/clash-forAutoDL/issues) 寻找解决方法。由于空闲时间有限，后续将不再对Issues中 “已经解答”、“已有解决方案” 的问题进行重复性的回答。

<br>

# 使用教程

## 下载项目

下载项目

```bash
git clone https://github.com/VocabVictor/clash-for-AutoDL.git
```

或者尝试kgithub(GitHub镜像站)下载

```bash
git clone https://kkgithub.com/VocabVictor/clash-for-AutoDL.git
```

![1.png](https://s2.loli.net/2024/06/20/8e4VzyTYZSGhPsC.png)

进入到项目目录，编辑`.env`文件，修改变量`CLASH_URL`的值。

```bash
cd clash-for-AutoDL
cp .env.example .env
vim .env
```

![2.png](https://s2.loli.net/2024/06/20/OXfREWDBgvjw4Kb.png)

![3.png](https://s2.loli.net/2024/06/20/S4t8ZlVjiOKuo7n.png)

> **注意：** `.env` 文件中的变量 `CLASH_SECRET` 为自定义 Clash Secret，值为空时，脚本将自动生成随机字符串。

<br>

## 启动程序

直接运行脚本文件`start.sh`

- 进入项目目录

```bash
cd clash-for-AutoDL
```

![4.png](https://s2.loli.net/2024/06/20/9yz4WwdoqrsCQt2.png)

由于现在AutoDL平台上的所有镜像都没有lsof，该工具是脚本中检测端口是否被占用的，所以需要安装一下。

```bash
apt-get update
apt-get install lsof
```

![5.png](https://s2.loli.net/2024/06/20/otEXxVMDOrez62Q.png)

- 运行启动脚本

```bash
source start.sh

正在检测订阅地址...
Clash订阅地址可访问！                                      [  OK  ]

正在下载Clash配置文件...
配置文件config.yaml下载成功！                              [  OK  ]
日志文件 logs/clash.log 已存在。

正在启动Clash服务...
服务启动成功！                                             [  OK  ]

Clash Dashboard 访问地址: http://<ip>:6006/ui
Secret: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

已添加代理函数到 .bashrc，并设置为自动执行。\n
请执行以下命令启动系统代理: proxy_on

若要临时关闭系统代理，请执行: proxy_off

若需要彻底删除，请调用: shutdown_system

[√] 已开启代理

```

![6.png](https://s2.loli.net/2024/06/20/txmaFbIAQpY2nES.png)


- 检查服务端口

```bash
lsof -i -P -n | grep LISTEN | grep -E ':6006|:789[0-9]'

tcp        0      0 127.0.0.1:6006          0.0.0.0:*               LISTEN     
tcp6       0      0 :::7890                 :::*                    LISTEN     
tcp6       0      0 :::7891                 :::*                    LISTEN     
tcp6       0      0 :::7892                 :::*                    LISTEN
```

![7.png](https://s2.loli.net/2024/06/20/WMVzH431c8gARPw.png)

6006是AutoDL平台上，GPU服务器唯一开放的外网端口。在官方没有修改端口的情况下，请勿修改相关配置。

- 检查环境变量

```bash
env | grep -E 'http_proxy|https_proxy'
http_proxy=http://127.0.0.1:7890
https_proxy=http://127.0.0.1:7890
```

![8.png](https://s2.loli.net/2024/06/20/niajqWtDpfZTJdV.png)

以上步骤如果正常，说明服务clash程序启动成功，现在就可以体验高速下载github资源了。

<br>

## 重启程序

如果需要对Clash配置进行修改，请修改 `conf/config.yaml` 文件。然后运行 `restart.sh` 脚本进行重启。

> **注意：**
> 重启脚本 `restart.sh` 不会更新订阅信息。

<br>

## 停止程序

- 临时停止

```bash
proxy_off
```
![9.png](https://s2.loli.net/2024/06/20/FwoBc6COzYybl5Z.png)

- 彻底停止程序

```bash
shutdown_system
```

![10.png](https://s2.loli.net/2024/06/20/p6CmIkvycFzTHiE.png)

然后检查程序端口、进程以及环境变量`http_proxy|https_proxy`，若都没则说明服务正常关闭。

<br>

## Clash Dashboard

- 访问 Clash Dashboard

通过浏览器访问 `start.sh` 执行成功后输出的地址，例如：<http://192.168.0.1:6006/ui>

- 登录管理界面

在`API Base URL`一栏中输入：http://\<ip\>:6006 ，在`Secret(optional)`一栏中输入启动成功后输出的Secret。

点击Add并选择刚刚输入的管理界面地址，之后便可在浏览器上进行一些配置。

- 更多教程

此 Clash Dashboard 使用的是[yacd](https://github.com/haishanh/yacd)项目，详细使用方法请移步到yacd上查询。

<br>

# 常见问题

1. 部分Linux系统默认的 shell `/bin/sh` 被更改为 `dash`，运行脚本会出现报错（报错内容一般会有 `-en [ OK ]`）。建议使用 `bash xxx.sh` 运行脚本。

2. 部分用户在UI界面找不到代理节点，基本上是因为厂商提供的clash配置文件是经过base64编码的，且配置文件格式不符合clash配置标准。

   目前此项目已集成自动识别和转换clash配置文件的功能。如果依然无法使用，则需要通过自建或者第三方平台（不推荐，有泄露风险）对订阅地址转换。

3. 程序日志中出现`error: unsupported rule type RULE-SET`报错，解决方法查看官方[WIKI](https://github.com/Dreamacro/clash/wiki/FAQ#error-unsupported-rule-type-rule-set)
