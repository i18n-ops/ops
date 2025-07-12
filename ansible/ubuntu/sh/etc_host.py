#!/usr/bin/env python

with open("/etc/hosts", "r") as file:
    lines = file.readlines()

seen = set()

output = []

for line in reversed(lines):
    line = line.strip()
    if line.startswith("#") or "localhost" in line:
        output.append(line)
        continue
    parts = line.split()
    if len(parts) == 2:
        hostname = parts[1]
        if hostname not in seen:
            seen.add(hostname)
            output.append(line)
    else:
        output.append(line)

output.reverse()

# 写入新的 /etc/hosts 文件内容
with open("/etc/hosts", "w") as file:
    file.write("\n".join(output) + "\n")
