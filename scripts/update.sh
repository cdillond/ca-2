#! /bin/bash

/home/admin/ca-2/lock.sh "automatic backup $(date)"
status=$?
if [ $status -ne 0 ]
then
    exit $status
fi

runuser -u admin /home/admin/ca-2/scripts/pull_live.sh
exit $?