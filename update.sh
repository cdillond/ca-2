#! /bin/bash

if [ $(id -u) -ne 0 ]
then
    echo "lock.sh must be run with root privileges" >&2
    exit 1
fi

/home/admin/ca-2/lock.sh "automatic backup $(date)"
runuser -u admin /home/admin/ca-2/pull_live.sh