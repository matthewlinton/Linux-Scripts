#!/bin/sh

netstat -n | grep ^tcp | sed \
-e "s/[0-9]*.[0-9]*.[0-9]*.[0-9]*://" \
-e "s/ 0 //g" \
-e "s/tcp//g" \
-e "s/^[ ]*//" \
-e "s/ESTABLISHED//g"
