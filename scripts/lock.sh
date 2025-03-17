#! /bin/bash

if [ $(id -u) -ne 0 ]
then
    echo "ERROR: lock.sh must be run with root privileges" >&2
    exit 1
fi

intranet=/var/www/html/intranet
# Restricting access to $intranet while the backup is in
# progress turns out to be somewhat complicated. I'm implementing
# it in three steps.
#
# 1) Reduce group privileges on the dir to disallow writes.
#    This prevents group members from adding or deleting new files,
#    but they can still make changes to files in $intranet that they created/own.
#    This has no effect on files in subdirectories.
chmod 755 $intranet
if [ $? -ne 0 ]
then
    echo "ERROR: unable to update permissions on $intranet to 755" >&2
    exit 1
fi
# 
# 2) Change the group on $intranet to apache. This prevents subsequent steps from 
#    disrupting access to the intranet site. It is fine for now
#    because apache's permissions level is unchanged.
chown admin:apache $intranet
if [ $? -ne 0 ]
then
    echo "ERROR: unable to update ownership of $intranet to admin:apache" >&2
    # attempt to roll back permissions change
    chmod 775 $intranet
    exit 1
fi
#
# 3) Disallow all access to $intranet by users other than admin and
#    apache. This should prevent any changes to files in $intranet or
#    its subdirectories from being made by non-admin users. Changes
#    to the content of files located outside the $intranet directory
#    referenced by symbolic links within the $intranet directory can
#    still be made -- however, apache is set up to only serve files 
#    within /var/www/html so those files will never be visible to clients
#    unless they are located in /var/www/html/live, in which case the
#    write access is already restricted.
chmod 750 $intranet
if [ $? -ne 0 ]
then
    echo "ERROR: unable to update permissions on $intranet to 750" >&2
    # attempt to roll back previous changes
    chown admin:employees $intranet
    chmod 775 $intranet
    exit 1
fi

