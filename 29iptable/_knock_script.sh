#!/bin/bash
HOST=$1
shift
for ARG in "$@"
do
        nmap -Pn --host-timeout 0 --max-retries 0 -p $ARG $HOST
done