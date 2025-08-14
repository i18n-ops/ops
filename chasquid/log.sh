#!/usr/bin/env bash

exec journalctl -f --no-pager --no-hostname -u chasquid
