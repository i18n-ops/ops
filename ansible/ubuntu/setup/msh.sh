#!/usr/bin/env bash

set -ex

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
wait -n || true

# If any script exits, kill all others / 如果有脚本退出，杀掉所有其他脚本
for pid in "${pids[@]}"; do
  kill -9 "$pid" 2>/dev/null || true
done
