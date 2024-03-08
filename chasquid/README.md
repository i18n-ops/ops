# 搭建自己的 SMTP 邮件发送服务器

## 序言

SMTP 可以直接购买云厂商的服务，比如 :

* [Amazon SES SMTP](https://docs.aws.amazon.com/ses/latest/dg/send-email-smtp.html)
* [阿里云邮件推送](https://www.alibabacloud.com/help/directmail/latest/three-mail-sending-methods)

也可以自己搭建邮件服务器 —— 发送不限量，综合成本低。

下面，我们一步一步的演示如何自建邮件服务器。

## 服务器选购

自托管的 SMTP 服务器需要开放了 25、456、587 端口的公网 IP。

常用的公有云默认都封禁了这些端口，发工单可能可以开通，但终归很麻烦。

我建议从那些开放了这些端口并支持设置反向域名的主机商中选购。

在这里，我推荐下 [Contabo](https://contabo.com) 。

Contabo 是总部位于德国慕尼黑的主机提供商，成立于 2003 年，价格极具竞争力。

购买币种选择欧元，价格会更便宜 (8GB 内存 4 CPU 的服务器约 529 元人民币每年，买一年免初装费)。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/UoAQkwY.webp)

下单时备注 `prefer AMD`, 选用 AMD CPU 的服务器，性能更佳。

后文，我将以 Contabo 的 VPS 为例，演示如何搭建自己的邮件服务器。

## Ubuntu 系统配置

这里操作系统选用 Ubuntu 22.04

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/smpIu1F.webp)

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/m7Mwjwr.webp)

如果 ssh 上服务器显示 `Welcome to TinyCore 13!`（如下图），表示这时候系统还没装完，请断开 ssh，等待几分钟再次登录。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/-qKACz9.webp)

出现 `Welcome to Ubuntu 22.04.1 LTS` 就是初始化完成，可以继续下面的步骤了。

### [可选] 初始化开发环境

这一步是可选的。

为了方便，我把 ubuntu 软件的安装、系统配置放到了 [github.com/user-tax-dev/os/tree/main/ubuntu](https://github.com/user-tax-dev/os/tree/main/ubuntu)。

运行以下指令可一键安装。

```
bash <(curl -s https://raw.githubusercontent.com/user-tax-dev/os/main/ubuntu/boot.sh)
```

中国用户请改用下面的指令，会自动设置语言、时区等。

```
CN=1 bash <(curl -s https://ghproxy.com/https://raw.githubusercontent.com/user-tax-dev/os/main/ubuntu/boot.sh)
```

### Contabo 启用 IPV6

启用 IPV6 ，这样 SMTP 也可以发送 IPV6 地址的邮件了。

编辑 `/etc/sysctl.conf`

修改或加入下面几行

```
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
```

接下来参考 [contabo 教程 : 将 IPv6 连接添加到您的服务器](https://contabo.com/blog/adding-ipv6-connectivity-to-your-server/)

编辑 `/etc/netplan/01-netcfg.yaml`, 加上如下图所示几行 ( Contabo VPS 默认配置文件已经有这些行，取消注释即可 )。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/5MEi41I.webp)

然后 `netplan apply` 让修改后的配置生效。

配置成功后，可使用 `curl 6.ipw.cn` 查看自己外网的 ipv6 地址。

## 克隆配置仓库 ops

```
git clone https://github.com/user-tax/ops.git
```

## 生成域名 免费 SSL 证书

发送邮件需要 SSL 证书加密和签名。

我们使用 [acme.sh](https://github.com/acmesh-official/acme.sh) 来生成证书。

acme.sh 是开源的自动化证书签发工具，

进入配置仓库 ops ，运行 `./ssl.sh`，会在上一级目录创建 `conf` 文件夹。

目录结构如下图：

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/W2occKn.webp)

从 [acme.sh dnsapi](https://github.com/acmesh-official/acme.sh/wiki/dnsapi) 中找到你的 DNS 服务商，编辑 `conf/conf.sh` 。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/Qjq1C1i.webp)

然后运行 `./ssl.sh 123.com`，就可以为你的域名生成 `123.com` 以及`*.123.com` 证书。

首次运行会自动安装[acme.sh](https://github.com/acmesh-official/acme.sh)，并添加自动续期的定时任务。`crontab -l` 就可以看到，有如下这么一行。

```
52 0 * * * "/mnt/www/.acme.sh"/acme.sh --cron --home "/mnt/www/.acme.sh" > /dev/null
```

生成的证书的路径类似 `/mnt/www/.acme.sh/123.com_ecc。`

证书续期会调用 `conf/reload/123.com.sh` 脚本，编辑这个脚本，可以添加诸如 `nginx -s reload` 的指令来刷新相关应用的证书缓存。

[howto.md](https://github.com/albertito/chasquid/blob/master/docs/howto.md) chasquid
也需要重启

## 用 chasquid 搭建 SMTP 服务器

[chasquid](https://github.com/albertito/chasquid) 是 Go 语言编写的开源 SMTP 服务器。

作为 Postfix、Sendmail 这些古老的邮件服务器程序的替代品，chasquid 更加简单易上手，也更容易二次开发。

运行 chasquid 配置仓库中的 `./chasquid/init.sh 123.com` 会全自动一键安装（替换 123.com 为你的发信域名）。

## 配置邮件签名 DKIM

DKIM 用于发送邮件的签名，避免信件被当成垃圾邮件。

命令成功运行后，会提示你去设置 DKIM 记录（如下图）。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/LJWGsmI.webp)

到你的 DNS 添加 TXT 记录即可（如下图）。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/0szKWqV.webp)

## 查看服务状态 & 日志

 `systemctl status chasquid` 查看服务状态。

正常运行时状态如下图

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/CAwyY4E.webp)

 `grep chasquid /var/log/syslog` 或者 `journalctl -xeu chasquid` 可以查看出错日志。

## 反向域名配置

反向域名是让 IP 地址可以解析为对应的域名。

设置反向域名，能避免邮件被识别为垃圾邮件。

当邮件接收后，接收服务器将对发送服务器的 IP 地址进行反向域名解析，以确认发送服务器是否具有有效的反向域名。

如果发送服务器没有反向域名或者反向域名与发送服务器的 IP 地址不匹配，接收服务器可能会将该邮件识别为垃圾邮件或拒绝接收。

访问 [https://my.contabo.com/rdns](https://my.contabo.com/rdns)，配置如下图

![](https://i-01.eu.org/2024/01/hNTtC-9.webp)

您应该到您的服务器提供商处将反向解析 (PTR) 配置为“mail.example.com。

这很重要，因为一些垃圾邮件检查器会将其视为一个因素。

设置完反向域名后，记得配置此域名 ipv4 和 ipv6 的正向解析到该服务器。

## 编辑 chasquid.conf 的 hostname

修改 `conf/chasquid/chasquid.conf` 为反向域名的值。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/6Fw4SQi.webp)

接着运行 `systemctl restart chasquid` 重启服务。

## 备份 conf 到 git 仓库

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/Fier9uv.webp)

比如我备份 conf 文件夹到自己的 github 流程如下

首先创建私有仓库

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/ZSCT1t1.webp)

进入 conf 目录，然后提交到仓库

```
git init
git add .
git commit -m "init"
git branch -M main
git remote add origin git@github.com:user-tax-key/conf.git
git push -u origin main
```

## 添加发件用户

运行

```
chasquid-util user-add i@user.tax
```

可以添加发件用户

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/khHjLof.webp)

### 效验密码是否设置正确

```
chasquid-util authenticate i@user.tax --password=xxxxxxx
```

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/e92JHXq.webp)

添加完成用户 ,  `chasquid/domains/user.tax/users` 会有更新，记得提交到仓库。

## DNS 添加 SPF 记录

SPF ( Sender Policy Framework ) 是一种邮件验证技术，用于防范电子邮件欺诈。

它通过检查发件人的 IP 地址与其所声称的域名的 DNS 记录是否匹配来验证邮件发送者的身份，从而防止欺诈者发送伪造的电子邮件。

添加 SPF 记录，能尽可能避免邮件被识别为垃圾邮件。

如果你的域名服务器不支持 SPF 类型，添加 TXT 类型记录即可。

比如，`user.tax` 的 SPF 如下

`v=spf1 a mx include:_spf.user.tax include:_spf.google.com ~all`

`_spf.user.tax` 的 SPF

`v=spf1 a:smtp.user.tax ~all`

注意，我这里有 `include:_spf.google.com`, 这是因为后续我将在谷歌邮箱配置用 `i@user.tax` 做发信地址。

## DNS 配置 DMARC

DMARC 是（Domain-based Message Authentication, Reporting & Conformance）的缩写。

它用于获取 SPF 退信的情况（可能是配置错误导致，也可能是别人在冒充你发送垃圾邮件）。

添加 TXT 记录 `_dmarc`，

内容如下

```
v=DMARC1; p=quarantine; fo=1; ruf=mailto:ruf@user.tax; rua=mailto:rua@user.tax
```

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/k44P7O3.webp)

各个参数含义如下

### p (Policy)

表示如何处理未通过 SPF (Sender Policy Framework) 或 DKIM (DomainKeys Identified Mail) 验证的邮件。p 参数可以设置为以下三个值之一：

* none：不采取任何行动，仅将验证结果通过邮件报告机制反馈给发件人。
* quarantine：将未通过验证的邮件放入垃圾邮件文件夹，但不会直接拒绝邮件。
* reject：直接拒绝未通过验证的邮件。

### fo (Failure Options)

指定报告机制返回的信息量。它可以设置为以下值之一 :

* 0：报告所有邮件的验证结果
* 1：仅报告未通过验证的邮件
* d：仅报告域名验证失败
* s：仅报告 SPF 验证失败
* l：仅报告 DKIM 验证失败

### rua & ruf

* rua（Reporting URI for Aggregate reports）：接收聚合报告的邮件地址
* ruf（Reporting URI for Forensic reports）：接收详细报告的邮件地址

## 添加 MX 记录转发来信到谷歌邮箱

因为没找到免费的支持万能地址 （Catch-All，能接收任何发送到此域名的邮件，不限制前缀）的企业邮箱，所以我用 chasquid 把所有的邮件都转发到 我的 Gmail 信箱。

**如果你有自己付费的企业邮箱，请不要修改 MX，并跳过这一步。**

编辑 `conf/chasquid/domains/user.tax/aliases`, 设置转发邮箱

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/OBDl2gw.webp)

`*` 表示所有邮件，`i` 是上面创建的发信用户邮箱前缀。想转发邮件，每个用户都需要添加一行。

然后添加 MX 记录即可 (我这里直接指向反向域名的地址，如下图第一行) 。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/7__KrU8.webp)

配置完成后，可以用其他邮箱发件到 `i@user.tax` 和 `any123@user.tax` 看看是否能在 Gmail 收到信件。

如果不能收到，请检查 chasquid 的日志 (`grep chasquid /var/log/syslog`)。

## 用谷歌邮箱发送 i@user.tax 的邮件

谷歌邮箱收件之后，自然希望回信也用 `i@user.tax` 而不是 i.user.tax@gmail.com 。

访问 [https://mail.google.com/mail/u/1/#settings/accounts](https://mail.google.com/mail/u/1/#settings/accounts) ，点击 『添加其他电子邮件地址』。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/PAvyE3C.webp)

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/_OgLsPT.webp)

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/XIUf6Dc.webp)

接着，输入被转发到的邮箱收到的验证码即可。

最后，可以将其设置为默认发信地址（同时选择以相同地址回复）。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/a95dO60.webp)

如此，我们就完成了 SMTP 发信服务器的搭建以及同时用谷歌邮箱收发邮件。

## 发送测试邮件，检查配置是否成功

进入 `ops/chasquid`

运行 `direnv allow` 安装依赖 (前文一键初始化过程中已经安装 direnv 并且在 shell 添加了 hook)

然后运行

```
user=i@user.tax pass=xxxx to=iuser.link@gmail.com ./sendmail.coffee
```

参数含义如下

* user: SMTP 的用户名
* pass: SMTP 的密码
* to: 收件人

就可以发送测试邮件了。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/ae1iWyM.webp)

建议用 Gmail 收测试邮件，方便查看各项配置是否成功。

### TLS 标准加密

如下图，有这个小锁，表示 SSL 证书已经成功启用。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/SrdbAwh.webp)

然后点击『显示原始邮件』

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/qQQsdxg.webp)

### DKIM

如下图，Gmail 原始邮件页面显示 DKIM，即为 DKIM 配置成功。

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/03/an6aXK6.webp)

检查原始邮件头部的 Received，还可以看到发信地址是 IPV6，这表示 IPV6 也配置成功了。
