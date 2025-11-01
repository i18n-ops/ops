#!/usr/bin/env bash

set -ex

btrfs subvolume list / | rg "\.snapshot" | rg "/snapshot" | awk -F" " '{print $9}' | xargs -I {} btrfs subvolume delete /{}
btrfs subvolume list / | rg "\.snapshot" | awk -F" " '{print $9}' | xargs -I {} rm -rf /{}
