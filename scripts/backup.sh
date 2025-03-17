#! /bin/bash

# This script can handle [0, 2] args. The first arg is always
# interpreted as the commit message and the second arg is always
# interpreted as the file name. If 0 args are given, the user is
# prompted for a commit message by git. If the second arg is not
# provided, a default value of "." is used instead.

if [ $(whoami) != "admin" ]
then
    echo "ERROR: backup.sh must be run as admin" >&2
    exit 1
fi


cd /home/admin/ca-2/intranet.git
status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: unable to access intranet.git" >&2
    exit $status
fi

fileName=$2
if [ -z "$fileName" ]
then
    fileName="."
fi

# stage changes
git add $fileName
status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: unable to stage changes to /var/www/html/intranet" >&2
    exit $status
fi

# commit changes
# if the user failed to provide a commit message, $EDITOR will pop up
if [ -z "$1" ]
then
    git commit
else
    git commit -m "$1"
fi

status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: unable to commit changes to /var/www/html/intranet" >&2
fi
exit $status