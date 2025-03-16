#! /bin/bash

if [ $(whoami) != "admin" ]
then
    echo "update script must be run as admin" >&2
    exit 1
fi


# pull changes to live
cd /home/admin/ca-2/live.git
git pull origin main
exit $?