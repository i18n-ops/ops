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

[ipv6_proxy](https://atomgit.com/i18n-in/ipv6_proxy)

### 定时任务

#### u2

[bak : 本机 kvrocks & mariadb 的 btrfs 快照](https://atomgit.com/i18n-ops/ops/blob/dev/bak/cron/u2)

[mycron : 定时任务 (比如抓取汇率 , 更新屏蔽的一次性邮箱域名等等)](https://atomgit.com/i18n/srv/tree/dev/rust/mycron)

### 监控报警

[前端展示](https://status.i18n.site)

[后端代码 aliver](https://atomgit.com/3ti/rust/blob/main/aliver/README.md)

后端部署到 fly.io 免费服务器 , 数据库用的免费数据库 aiven.io , 分钟级监控。


## 数据库恢复

1. mariadb
rm -rf /mnt/data/i18n/mariadb/data  && /opt/ops/mariadb/rebuild_slave.sh 193.22.146.61
然后运行 ./iptable/mariadb.sh
最后在主库上运行 ./mariadb/init.user.sh
2. kvrocks
服务器bgsave 之后 把 backup 同步到每台机器的 /mnt/data/i18n/kvrocks/db
