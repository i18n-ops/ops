# contabo 配置备忘

## 如何把根分区从 ext4 转为 btrfs

如果不是干净的系统，可以先重装

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/LsAN4pZ.webp)

重装的话，请先等待 `Status` 变为 `finish`，否则可能会导致错误。

然后进入救援系统 (参考 [System Rescue CD: First Steps](https://contabo.com/blog/system-rescue-cd-first-steps))

![](https://i-01.eu.org/2023/12/zKspEA5.webp)

系统选 Debian Rescue (recommended)

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/Wa2HdD1.webp)

ssh 的时候会出现指纹变化，用 `ssh-keygen -R ip` 来清理

```
nohup bash -c "bash <(curl -s https://atomgit.com/i18n-ops/ops/raw/main/contabo/ext4_btrfs.sh) >/tmp/nohup.out 2>&1 && reboot" &
tail -f /tmp/nohup.out
```

即可

[使用 Btrfs 快照进行增量备份](https://linux.cn/article-12653-1.html)

## 重新用 ssh 登录

因为救援系统和原系统的指纹不一样，需要重新扫描一下公钥

```
H=ip地址 bash -c 'ssh-keygen -R $H && ssh-keyscan -H $H >> ~/.ssh/known_hosts'
```

## 升级 ubuntu 并启用 ipv6

```
nohup bash <(curl -s https://atomgit.com/i18n-ops/ubuntu/raw/main/upgrade.sh) > /tmp/upgrade.nohup.out 2>&1 &
nohup bash <(curl -s https://atomgit.com/i18n-ops/ops/raw/main/contabo/ipv6.sh) > /tmp/ipv6.nohup.out 2>&1 &
sleep 1 && tail -f /tmp/*.nohup.out

```

如果升级不小心中断了，可以尝试

```
dpkg --configure -a
```

## 恢复公钥登录 & 给主机命名

在本地开发机（比如你的苹果笔记本）上运行 `../ssh/restore.sh 主机名`

## 安装常用软件

```
CN=1 bash <(curl -s https://ghproxy.com/https://raw.githubusercontent.com/wactax/ops.os/main/ubuntu/boot.sh)
```

## `btrfs` 使用细节

### 查看压缩率

默认会自动压缩，查看压缩率命令如下

```sh
if ! command -v compsize &>/dev/null; then
apt install -y  btrfs-compsize
fi
compsize -x /
```

### 手动压缩

如果有完美主义洁癖，也可以手动做一次全盘压缩，命令如下

```sh
btrfs filesystem defragment -r -czstd /
```

如下图，可以看到，新系统手动压缩之后，多压缩了接近 100MB。

![](https://i-01.eu.org/2023/12/8NWlr4c.webp)

### 数据库放到子卷，子卷可以被快照

在 `btrfs` 中，子卷可以理解为一个文件系统下面可以“虚拟”出很多文件系统出来。你可以使用以下命令来创建子卷：

```
cd /mnt
btrfs subvolume create xxx
```

这里，`xxx` 是你想要创建的子卷的名称。创建子卷后，会在 `/mnt` 目录下生成一个新的目录，这个目录就是你的子卷。

创建快照：在 `btrfs` 中，快照也是一种子卷，可以用来保存当前子卷的状态。你可以使用以下命令来创建快照：

```
btrfs subvolume snapshot /mnt/xxx /mnt/snapshot-name
```

这里，`xxx` 是你想要创建快照的子卷的名称，`snapshot-name` 是你想要创建的快照的名称。

以上步骤完成后，你就创建了一个可以被快照的子卷。
