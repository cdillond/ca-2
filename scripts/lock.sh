#! /bin/bash

if [ $(id -u) -ne 0 ]
then
    echo "lock.sh must be run with root privileges" >&2
    exit 1
fi

intranet=/var/www/html/intranet
# restricting access to the intranet while the backup is in
# progress turns out to be somewhat complicated. I'm implementing
# it in three steps.
#
# 1) reduce group privileges on the dir to disallow writes.
#    this prevents group members from adding or deleting new files,
#    but they can still make changes to files in $intranet that they created/own.
#    this has no effect on files in subdirectories.
chmod 755 $intranet
# 
# 2) change the group to apache. This prevents subsequent steps from 
#    disrupting access to the intranet site. it is also fine for now
#    because apache's permissions level is unchanged.
chown admin:apache $intranet
#
# 3) disallow all access to $intranet by users other than admin and
#    apache. this should prevent any changes to files in $intranet or
#    its subdirectories from being made by non-admin users.
chmod 750 $intranet

runuser -u admin /home/admin/ca-2/scripts/backup.sh "$1"
status=$?

# the previous permissions changes can now be undone. 
chmod 755 $intranet
chown admin:employees $intranet
chmod 775 $intranet

exit $status