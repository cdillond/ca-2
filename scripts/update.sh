#! /bin/bash

# this script must be run with superuser privileges
if [ $(id -u) -ne 0 ]
then
    echo "ERROR: update.sh must be run with superuser privileges; backup not completed" >&2
    exit 1
fi

/home/admin/ca-2/scripts/lock.sh
if [ $? -ne 0 ]
then
    echo "ERROR: failed to lock /var/www/html/intranet; backup not completed" >&2
    exit 1
fi

runuser -u admin /home/admin/ca-2/scripts/backup.sh 2 "automatic backup $(date)"
backup_status=$?

if [ $backup_status -ne 0 ]
then
    echo "ERROR: backup of /var/www/html/intranet failed" >&2
fi

/home/admin/ca-2/scripts/unlock.sh
if [ $? -ne 0 ]
then
    echo "ERROR: failed to unlock /var/www/html/intranet" >&2
    exit 1
fi

# only exit after unlocking the intranet dir
if [ $backup_status -ne 0 ]
then
    exit $backup_status
fi

runuser -u admin /home/admin/ca-2/scripts/pull_live.sh
if [ $? -ne 0 ]
then
    echo "ERROR: failed to update /var/www/html/live" >&2
    exit 1
fi