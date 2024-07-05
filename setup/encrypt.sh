#!/usr/bin/env bash

fp=$1
password=$2
encrypted_fp="${fp}.enc"

openssl enc -pbkdf2 -aes-256-cbc -md sha512 -salt -in "$fp" -out "$encrypted_fp" -pass pass:"$password"
