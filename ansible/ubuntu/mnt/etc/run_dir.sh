#!/usr/bin/env bash

if [ -d $1 ] ; then
for script in $1/*.sh ; do
if [ -r $script ] ; then
. $script
fi
done
fi
