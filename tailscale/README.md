对于在 Fly 这样的环境中运行的应用程序，所有相关的节点状态都存储在 `/var/lib/tailscale/tailscaled.state` 中。

要保留 IP 地址，您需要在重新部署应用程序时保存和恢复 `/var/lib/tailscale/tailscaled.state` 文件。

为了实现这一点，一次只运行一个容器非常重要。如果两个节点尝试使用相同的 `tailscaled.state` 文件，它们就会发生冲突。
