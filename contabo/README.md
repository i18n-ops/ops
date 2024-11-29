# contabo 配置备忘

## 重装流程

### 恢复公钥登录 & 给主机命名

在本地开发机（比如你的苹果笔记本）上运行 `../ssh/restore.sh 主机名 IP 密码`

### 把根分区从 ext4 转为 btrfs

如果不是干净的系统，可以先重装

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/LsAN4pZ.webp)

重装的话，请先等待 `Status` 变为 `finish`，否则可能会导致错误。

然后进入救援系统 (参考 [System Rescue CD: First Steps](https://contabo.com/blog/system-rescue-cd-first-steps))

![](https://i-01.eu.org/2023/12/zKspEA5.webp)

系统选 Debian Rescue (recommended)

![](https://pub-b8db533c86124200a9d799bf3ba88099.r2.dev/2023/08/Wa2HdD1.webp)

ssh 的时候会出现指纹变化，用 `ssh-keygen -R ip` 来清理

```
nohup bash -c "bash <(curl -s https://raw.githubusercontent.com/i18n-ops/ops/main/contabo/ext4_btrfs.sh) >/tmp/nohup.out 2>&1 && reboot" &
sleep 1 && tail -f /tmp/nohup.out
```

即可

[使用 Btrfs 快照进行增量备份](https://linux.cn/article-12653-1.html)

### 重新用 ssh 登录

因为救援系统和原系统的指纹不一样，需要重新扫描一下公钥

```
H=ip地址 bash -c 'ssh-keygen -R $H && ssh-keyscan -H $H >> ~/.ssh/known_hosts'
```

### 升级 ubuntu & 安装常用软件

```
enable_ipv6
nohup bash -c "bash <(curl -s https://raw.githubusercontent.com/i18n-ops/ops/main/contabo/init.sh) && reboot" >/tmp/init.log 2>&1 &
sleep 1 && tail -f /tmp/init.log
```

如果升级不小心中断了，可以尝试下面命令修复

```
dpkg --configure -a
```

## 备忘

### `btrfs` 使用细节

#### 查看压缩率

默认会自动压缩，查看压缩率命令如下

```sh
if ! command -v compsize &>/dev/null; then
apt install -y  btrfs-compsize
fi
compsize -x /
```

#### 手动压缩

如果有完美主义洁癖，也可以手动做一次全盘压缩，命令如下

```sh
btrfs filesystem defragment -r -czstd /
```

如下图，可以看到，新系统手动压缩之后，多压缩了接近 100MB。

![](https://i-01.eu.org/2023/12/8NWlr4c.webp)

#### 数据库放到子卷，子卷可以被快照

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

### 快照

```
~/ubuntu/snapper/init.sh
```

[用 snapper 轻松玩转 Btrfs 的快照功能](https://zhuanlan.zhihu.com/p/31082518)

## 救援系统

进入救援系统从 22 端口可以 [tcping](https://github.com/paradiseduo/tcping) 通之后 , 会有 2-3 分钟无法有设置的密码访问 , 等一下就好了

```
tcping ip 22 -c 9999
```

可以监控端口的可访问性

#### 进入救援之后怎么访问硬盘

```
mkdir -p /mnt/os
mount  /dev/sda3 /mnt/os -t btrfs -o "defaults,ssd,discard,noatime,compress=zstd:3,space_cache=v2"
mount --bind /dev /mnt/os/dev
mount --bind /proc /mnt/os/proc
mount --bind /sys /mnt/os/sys
mount --bind /run /mnt/os/run
chroot /mnt/os zsh -c "mount -a && dbus-daemon --system 2>/dev/null; exec zsh"
```

就可以查看快照了 , 比如

```
snapper -c etc list
```

查看快照文件改动

```
snapper -c etc status 5..6
```

查看具体差异文本

```
snapper -c etc diff 3..5
```

恢复快照 : 比如撤销快照 5 之后的所有改动

```
snapper -c etc undochange 1..0
snapper -c disk undochange 1..0
```

#### 开启日志持久化

在救援系统下开启日志持久化需要你手动创建对应的目录并执行一些额外步骤，因为你可能没有运行中的 systemd 服务。这里是你可以尝试的步骤：

先 chroot, 然后

```
mkdir -p /var/log/journal
chown root:systemd-journal /var/log/journal
chmod 2755 /var/log/journal
sed -i 's/^#\?\s*Storage=.*/Storage=persistent/' /etc/systemd/journald.conf
```

重启到你的 Ubuntu 系统：进行了以上更改后，你需要正常重启你的机器，并进入到你的 Ubuntu 系统中而不是救援系统。

这样，systemd-journald 会以新的配置启动，开始在硬盘上持久化地存储日志。

请记住，以上操作是在救援系统中进行的，因此一旦系统重启并且不再处于救援模式，那些改动才会生效。

这意味着你不会立刻看到任何已经存在的日志变成持久化的变化，但所有在这之后产生的日志会被持久保存。

这样可以查看 ssh 服务的日志

```
journalctl --directory=/var/log/journal  _SYSTEMD_UNIT=ssh.service
```

### 无法 ssh

我看日志貌似是权限问题 :

`Missing privilege separation directory: /run/sshd`

可以用下面命令来创建这个目录

```
chown root:root /
systemd-tmpfiles --create
```

经过排查 , 是下面的代码导致的 , github action 打包的用户是 1001

tar 解包必须如果没有 `--no-same-owner` , 会解压为 1001 用户

直接 rsync 会改变跟根目录的用户组 , 进而导致重启无法登录 ssh ( Missing privilege separation directory: /run/sshd )

  ```bash
tar --no-same-owner -xvf $TZT # 之前没加--no-same-owner
rm $TZT

if [ -f "init.sh" ]; then
  ./init.sh
  rm init.sh
fi

rsync --remove-source-files -av . /
```
