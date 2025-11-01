#!/usr/bin/env bash

set -e
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -x

mkdir -p build

NIXOS_VERSION=$(curl -s https://endoflife.date/api/nixos.json | jq -r '.[0].cycle')

if [[ -z "$NIXOS_VERSION" ]]; then
  echo "获取 NixOS 版本失败"
  exit 1
fi

sd 'nixpkgs.url = "github:NixOS/nixpkgs/nixos-.*";' "nixpkgs.url = \"github:NixOS/nixpkgs/nixos-${NIXOS_VERSION}\";" flake.nix
sd 'system.stateVersion = ".*";' "system.stateVersion = \"${NIXOS_VERSION}\";" configuration.nix

build_image() {
  local arch="$1"

  echo "正在构建 NixOS ${NIXOS_VERSION} ${arch} 架构镜像..."
  local out="build/nixos-${NIXOS_VERSION}.${arch}"
  nix build ".#image-${arch}" \
    --extra-experimental-features "nix-command flakes" \
    --system "${arch}-linux" \
    --option system-features "kvm big-parallel" \
    --max-jobs auto \
    --cores 0 \
    --out-link $out

  zstd -15 -o $out.zst $(realpath $out)/main.raw
  rm -rf $out
}

ARCH=$(uname -m)
case "$ARCH" in
arm64)
  build_image aarch64
  ;;
x86_64)
  build_image x86_64
  ;;
*)
  echo "未知的架构 $ARCH"
  exit 1
  ;;
esac

nix-collect-garbage

echo "构建完成！生成的镜像文件:"
ls -la build/
