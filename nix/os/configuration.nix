{ config,
  pkgs,
  lib,
  ...
}: {
  imports = [ ./soft.nix ];
  # 内核参数
  boot.kernelParams = [
    # 关闭内核的操作审计功能
    "audit=0"
    # 不要根据 PCIe 地址生成网卡名，而是直接根据顺序生成
    "net.ifnames=0"
  ];

  # Initrd 配置，开启 ZSTD 压缩和基于 systemd 的第一阶段启动
  boot.initrd = {
    compressor = "zstd";
    compressorArgs = ["-19" "-T0"];
    systemd.enable = true;
  };

  # 安装 Grub 引导器
  boot.loader.grub = {
    enable = !config.boot.isContainer;
    default = "saved";
    devices = ["/dev/sda"];
  };

  # 时区，根据你的所在地修改
  time.timeZone = "Asia/Shanghai";

  # Root 用户的密码和 SSH 密钥。如果网络配置有误，可以用此处的密码在控制台上登录进去手动调整网络配置
  # 默认密码: 我的最常用密码规则+符号版本
  users.mutableUsers = false;

  users.users.root = {
    hashedPassword = "$6$1NSYaw3Q9CaofLto$sxLokHKw4XMhcV.K248xuILwBIDPlQeT.rbIBVolAxLq3hxpuFJNFZzVmLXQ/KMDuN/xryrcy30kqhrSZbkcw1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmv9jX+DKrfZbKiZTk+LhPlIAoyFeVEraFaxKk29mvc m2.i18n"
    ];

  };

  # 预装的系统软件包
  environment.systemPackages = with pkgs; [

  ];

  environment.etc."nixos/soft.init.nix".source = ./soft.init.nix;

  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"      # 持久化 NixOS 配置
      "/var/log"        # 持久化日志
      "/etc/ssh"        # 持久化 SSH 主机密钥
      "/var/lib/nixos"  # 持久化 NixOS 状态，避免 UID/GID 重新分配
    ];
  };

  # 使用 systemd-networkd 管理网络
  systemd.network.enable = true;
  networking.useNetworkd = true;
  networking.enableIPv6 = true;
  networking.useDHCP = false;
  services.resolved.enable = false;

  # 配置 DNS 服务器（Cloudflare + Google）
  networking.nameservers = [
    # IPv4
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
    # IPv6
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];

  # 使用 systemd-networkd 配置 DHCP
  systemd.network.networks."10-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = "yes";
      DNS = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
        "2001:4860:4860::8888"
        "2001:4860:4860::8844"
      ];
    };
  };

  # 开启 SSH 服务端
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkForce "prohibit-password";
    };
  };

  # 关闭 NixOS 自带的防火墙
  networking.firewall.enable = false;

  # 主机名，随意设置即可
  networking.hostName = "nixos-vps";

  # 首次安装系统时 NixOS 的最新版本，用于在大版本升级时避免发生向前不兼容的情况
  system.stateVersion = "25.05";

  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];

  # BTRFS subvolume-per-boot impermanence script
  boot.initrd.systemd.services.btrfs-subvolume-setup = {
    description = "BTRFS subvolume per boot setup";
    wantedBy = [ "initrd.target" ];
    requires = [ "dev-disk-by-label-root.device" ];
    after = [ "dev-disk-by-label-root.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
    script = ''
      mount -o subvol=/ /dev/disk/by-label/root /mnt
      mkdir -p /mnt/old

      if [ -d "/mnt/@root" ]; then
        timestamp=$(date --date="@$(stat -c %Y /mnt/@root)" +%Y-%m-%d-%H-%M-%S)
        mv /mnt/@root /mnt/old/@root-$timestamp
        find /mnt/old -maxdepth 1 -type d -name '@root-*' -mtime +7 -exec btrfs subvolume delete {} \;
      fi
      btrfs subvolume create /mnt/@root
      umount /mnt
    '';
  };

  # Disko 磁盘分区配置
  disko = {
    # 不要让 Disko 直接管理 NixOS 的 fileSystems.* 配置
    # 原因是 Disko 默认通过 GPT 分区表的分区名挂载分区，但分区名很容易被 fdisk 等工具覆盖掉
    # 导致一旦新配置部署失败，磁盘镜像自带的旧配置也无法正常启动
    enableConfig = false;

    devices = {
      # 定义一个磁盘
      disk.main = {
        # 要生成的磁盘镜像的大小，2GB 足够使用，可以按需调整
        imageSize = "2G";
        # 磁盘路径。Disko 生成磁盘镜像时，实际上是启动一个 QEMU 虚拟机走一遍安装流程
        # 因此无论你的 VPS 上的硬盘识别成 sda 还是 vda，这里都以 Disko 的虚拟机为准，指定 vda
        device = "/dev/vda";
        type = "disk";
        # 定义这块磁盘上的分区表
        content = {
          # 使用 GPT 类型分区表。Disko 对 MBR 格式分区的支持似乎有点问题
          type = "gpt";
          # 分区列表
          partitions = {
            # GPT 分区表不存在 MBR 格式分区表预留给 MBR 主启动记录的空间，因此这里需要预留
            # 硬盘开头的 1MB 空间给 MBR 主启动记录，以便后续 Grub 启动器安装到这块空间
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
              # 优先级设置为最高，保证这块空间在硬盘开头
              priority = 0;
            };

            # ESP 分区，或者说是 boot 分区。这套配置理论上同时支持 EFI 模式和 BIOS 模式启动的 VPS
            ESP = {
              name = "ESP";
              # 根据个人需求预留 512MB 空间。如果你的 boot 分区占用更大/更小，可以按需调整
              size = "512M";
              type = "EF00";
              # 优先级设置成第二高，保证在剩余空间的前面
              priority = 1;
              # 格式化成 FAT32 格式
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [ "-n" "ESP" ];
                # 用作 Boot 分区，Disko 生成磁盘镜像时根据此处配置挂载分区，需要和 fileSystems.* 一致
                mountpoint = "/boot";
                mountOptions = ["fmask=0077" "dmask=0077"];
              };
            };


            # 存放 NixOS 系统的分区，使用剩下的所有空间
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "root" ];
                # 不挂载顶层卷，只挂载子卷
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress-force=zstd" "nosuid" "nodev"];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress-force=zstd" "nosuid" "nodev"];
                  };
                  "@data" = {
                    mountpoint = "/data";
                    mountOptions = ["nodatacow" "noatime" "compress=zstd"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # 根据 disko 生成的磁盘镜像布局，统一文件系统挂载配置
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      # subvol 将由 initrd 脚本动态创建和指定
      options = [ "subvol=@root" "compress-force=zstd" "nosuid" "nodev" ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress-force=zstd" "nosuid" "nodev" ];
      neededForBoot = true;
    };
    "/persist" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = [ "subvol=@persist" "compress-force=zstd" "nosuid" "nodev" ];
      neededForBoot = true;
    };
    "/data" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = ["subvol=@data" "nodatacow" "noatime" "compress=zstd"];
    };
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
      neededForBoot = true;
    };
  };

  systemd.services.first-boot-setup = {
    description = "init soft";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
    script = ''
      if [ -f /etc/nixos/soft.init.nix ]; then
        mv /etc/nixos/soft.init.nix /etc/nixos/soft.nix
        nixos-rebuild switch
        systemctl disable first-boot-setup.service
        systemctl stop first-boot-setup.service
      fi
    '';
  };
}
