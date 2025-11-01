# 在 Contabo-VPS 上安装 NixOS

这份小指南描述了如何引导 Nix 在 Contabo-VPS 服务器上安装 NixOS：

创建 `/nix` 并使用 `tmpfs`，否则磁盘很快就会满

```bash
mkdir /nix
mount -t tmpfs tmpfs /nix -o size=5g
```

创建 nix-build 用户

```bash
groupadd nixbld
for n in $(seq 1 10); do useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin)" "nixbld$n"; done
```

安装 Nix

```bash
bash <(curl -L https://nixos.org/nix/install)
. $HOME/.nix-profile/etc/profile.d/nix.sh
nix-channel --add https://nixos.org/channels/nixos-22.05 nixpkgs
```

设置 nixpkgs

```bash
nix-env -iE "_: with import <nixpkgs/nixos> { configuration = {}; }; with config.system.build; [ nixos-generate-config nixos-install nixos-enter manual.manpages ]"
```

现在按照您希望的方式分区磁盘并将其挂载到 `/mnt`。Contabo 支持 UEFI，但我尝试了多种方法，只有 BIOS 模式有效。

```bash
mount /dev/sda1 /mnt
```

接下来生成配置

```bash
nixos-generate-config --root /mnt
```

确保您的配置中包含以下行：

```nix
{ config, lib, pkgs, ... }:

{
  boot.initrd = {
    availableKernelModules = [
      "virtio_pci"  # 磁盘
      "virtio_scsi" # 磁盘
    ];
    kernelModules = [
      "dm-snapshot"
    ];
  };
}
```

安装 NixOS

```bash
nixos-install
```

重启后，请确保 nix-channels 是最新的

```bash
nix-channel --add https://nixos.org/channels/nixos-22.05 nixos
nixos-rebuild switch --upgrade
```