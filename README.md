## 服务器初始化

[contabo](./contabo) contabo 服务器初始化

初始化之后

```
./ssh/restore.sh 主机名 ip 密码
```

## cloudflare

[cloudflare/main.coffee](./cloudflare/main.coffee) cloudflare 域名初始化
[cloudflare/b2.coffee](./cloudflare/b2.coffee) cloudflare 映射到 [backblaze.com](http://backblaze.com)

## 服务器部署了的服务

### u1 & u2 & u3

kvrocks
mariadb
chasquid
[ipv6_proxy](https://atomgit.com/i18n-in/ipv6_proxy)

### 定时任务

#### u2

[bak : 本机 kvrocks & mariadb 的 btrfs 快照](https://atomgit.com/i18n-ops/ops/blob/dev/bak/cron/u2)

[mycron : 定时任务 (比如抓取汇率 , 更新屏蔽的一次性邮箱域名等等)](https://atomgit.com/i18n/srv/tree/dev/rust/mycron)

### 监控报警

[前端展示](https://status.i18n.site)

[后端代码 aliver](https://atomgit.com/3ti/rust/blob/main/aliver/README.md)

后端部署到 fly.io 免费服务器 , 数据库用的免费数据库 aiven.io , 分钟级监控。
