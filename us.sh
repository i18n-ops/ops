#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "USAGE : $0 CMD"
  exit 1
fi

exec pdsh -w "us1 us2 us3" -R ssh $@
