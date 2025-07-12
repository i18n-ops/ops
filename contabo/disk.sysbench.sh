#!/usr/bin/env bash

apt install -y sysbench
mkdir -p /tmp/sysbench
cd /tmp/sysbench
sysbench --num-threads=32 --report-interval=4 --time=60 --test=fileio --file-num=10 --file-total-size=10G --file-test-mode=rndrw prepare
sysbench --num-threads=32 --report-interval=4 --time=60 --test=fileio --file-num=10 --file-total-size=10G --file-test-mode=rndrw run
sysbench --num-threads=32 --report-interval=4 --time=60 --test=fileio --file-num=10 --file-total-size=10G --file-test-mode=rndrw cleanup
rm -rf /tmp/sysbench
