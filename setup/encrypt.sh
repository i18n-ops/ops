#!/usr/bin/env bash

# 用管道输入
# password file_path

cat $2 | gpg --symmetric --batch --passphrase "$1" --cipher-algo AES256 -o $2.gpg
