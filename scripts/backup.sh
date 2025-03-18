#! /bin/bash

# This script should be invoked with at least 1 and no more 
# than 3 args. The first argument must always be a mask, 
# indicating which of the two other args have also been provided:
# 1<<0: file name is provided
# 1<<1: commit message is provided
# This results in the following scenarios:
# 0 --> git add . && git commit
# 1 --> git add $2 && git commit
# 2 --> git add . && git commit -m "$2"
# 3 --> git add $2 && git commit -m "$3"
#
# valid usages include:
# ./backup.sh 0 
# ./backup.sh 1 filename.txt
# ./backup.sh 2 "message"
# ./backup.sh 3 filename.txt "message"

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

fileName="."
message=""
case $1 in
    0)  ;;
    1)  fileName="$2" ;;
    2)  message="$2" ;;
    3)  fileName="$2"
        message="$3" ;;
    *)  ;;
esac

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
# if the user doesnt provide a commit message, $EDITOR will pop up
if [ -z "$message" ]
then
    git commit
else
    git commit -m "$message"
fi

status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: unable to commit changes to /var/www/html/intranet" >&2
    exit $status
fi
