#!/usr/bin/env bash

# password fp outfp

gpg --decrypt --batch --passphrase "$1" "$2" | tar --use-compress-program=zstd -xv -C $3
