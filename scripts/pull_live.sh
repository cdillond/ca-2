#! /bin/bash

if [ $(whoami) != "admin" ]
then
    echo "ERROR: pull_live.sh must be run as admin" >&2
    exit 1
fi

cd /home/admin/ca-2/live.git
if [ $? -ne 0 ]
then
    echo "ERROR: unable to access live.git" >&2
    exit 1
fi

git pull origin main
if [ $? -ne 0 ]
then
    echo "ERROR: unable to pull changes to live.git" >&2
    exit 1
fi