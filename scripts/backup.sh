#! /bin/bash

if [ $(whoami) != "admin" ]
then
    echo "backup script must be run as admin" >&2
    exit 1
fi

cd /home/admin/ca-2/intranet.git
# stage all changes
git add .
git commit -m "$1"