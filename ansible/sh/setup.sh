#!/usr/bin/env bash

if ! command -v ansible &>/dev/null; then
  echo "安装 Ansible / Setup Ansible"

  if command -v apt-get &>/dev/null; then
    # 使用 apt-get 安装 Ansible (适用于 Debian/Ubuntu)
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
  elif command -v yum &>/dev/null; then
    # 使用 yum 安装 Ansible (适用于 CentOS/RHEL)
    sudo yum install -y epel-release
    sudo yum install -y ansible
  elif command -v dnf &>/dev/null; then
    # 使用 dnf 安装 Ansible (适用于 Fedora)
    sudo dnf install -y ansible
  elif command -v zypper &>/dev/null; then
    # 使用 zypper 安装 Ansible (适用于 openSUSE)
    sudo zypper install -y ansible
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # 检查是否安装了 Homebrew
    if ! command -v brew &>/dev/null; then
      bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install ansible
  else
    echo -e "无法识别的包管理器，无法自动安装 Ansible\nUnrecognized package manager, unable to automatically install Ansible"
    exit 1
  fi
fi

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR

# if [ ! -d "plugin/mitogen/ansible_mitogen/plugins/strategy" ]; then
#   cd plugin
#   rm -rf mitogen
#   latest_release=$(curl -s https://api.github.com/repos/mitogen-hq/mitogen/releases/latest | jq -r .tag_name)
#   git clone --depth=1 --branch $latest_release https://github.com/mitogen-hq/mitogen.git
# fi
