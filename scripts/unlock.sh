#! /bin/bash

if [ $(id -u) -ne 0 ]
then
    echo "ERROR: unlock.sh must be run with root privileges" >&2
    exit 1
fi

intranet=/var/www/html/intranet
# the permissions and ownership changes made by lock.sh can now be undone. 
# if any of these commands fail, it's a problem that
# needs to be dealt with by the admin. If exiting early,
# the $intranet dir will remain locked or partially locked.
# But, if errors are ignored, then the system might end up in
# a state where, e.g., apache has greater privileges than it's supposed to.
chmod 755 $intranet
if [ $? -ne 0 ]
then
    echo "ERROR: unable to update permissions on $intranet to 755" >&2
    exit 1
fi

chown admin:employees $intranet
if [ $? -ne 0 ]
then
    echo "ERROR: unable to update ownership of $intranet to admin:employees" >&2
    exit 1
fi

chmod 775 $intranet
if [ $? -ne 0 ]
then
    echo "ERROR: unable to update permissions on $intranet to 775" >&2
    exit 1
fi