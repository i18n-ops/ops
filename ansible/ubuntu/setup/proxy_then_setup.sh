#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

# Function to run multiple scripts concurrently and kill others if one exits
# 并发运行多个脚本，如果任意一个退出，则杀掉其他脚本
msh() {
  # Create an array to store PIDs / 创建一个数组存储PID
  declare -a pids

  # Loop through each script path / 遍历每个脚本路径
  for script in "$@"; do
    # Run the script in the background and store its PID / 后台运行脚本并存储其PID
    $script &
    pids+=($!)
    sleep 3
  done

  # Wait for any child process to exit / 等待任意子进程退出
  wait -n

  # If any script exits, kill all others / 如果有脚本退出，杀掉所有其他脚本
  for pid in "${pids[@]}"; do
    kill -9 "$pid" 2>/dev/null || true
  done
}

if [ -n "$GFW" ]; then
  ./clash.init.sh
  export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
  msh /usr/local/bin/clash ./proxyed_setup.sh
else
  ./proxyed_setup.sh
fi
