#!/usr/bin/env python3

import sys


def btrfs_device():
    with open("/proc/mounts", "r") as f:
        for line in f:
            parts = line.split()
            device, mountpoint, fstype = parts[0], parts[1], parts[2]

            if fstype == "btrfs" and mountpoint == "/":
                return device
    return


def main():
    device = btrfs_device()
    if not device:
        return

    li = []

    with open("/etc/fstab", "r") as fstab:
        for line in fstab:
            line = line.rstrip("\n")
            if not line.lstrip().startswith("#"):
                t = line.split()
                if len(t) > 1:
                    if t[1].endswith("/.snapshots"):
                        continue
            li.append(line)

    for i in sys.argv[1:]:
        if i == "/":
            fp = "bak/disk"
        else:
            fp = "bak/" + i
            i = "/" + i + "/"

        line = f"{device} {i}.snapshots btrfs defaults,ssd,discard,noatime,compress=zstd:3,space_cache=v2,autodefrag,subvol={fp} 0 0"
        li.append(line)

    with open("/etc/fstab", "w") as fstab:
        fstab.write("\n".join(li))


if __name__ == "__main__":
    main()
