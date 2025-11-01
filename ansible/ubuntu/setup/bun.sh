#!/usr/bin/env bash

. env.sh

export BUN_INSTALL=/opt/bun

BUN=$BUN_INSTALL/bin/bun

if [ -f "$BUN" ]; then
  $BUN upgrade
else
  $CURL https://bun.sh/install | GITHUB=${GITHUB_PROXY}https://github.com bash
fi
