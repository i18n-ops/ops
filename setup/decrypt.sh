#!/usr/bin/env bash

fp="$1"
password="$2"

openssl enc -md sha512 -pbkdf2 -d -aes-256-cbc -in "$fp.enc" -out "${fp}" -pass pass:"$password"
