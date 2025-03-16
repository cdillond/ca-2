#! /bin/bash

if [ $(whoami) != "admin" ]
then
    echo "backup script must be run as admin" >&2
    exit 1
fi

cd /home/admin/ca-2/intranet.git

# stage and commit all changes
git add .
status=$?
if [ $status -ne 0 ]
then
    exit $status
fi

git commit -m "$1"
exit $?