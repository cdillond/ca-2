#! /bin/bash

intranet=/var/www/html/intranet
live=/var/www/html/live

# flock -s places a read lock on the source directory 
# while the cp command executes.
#
# The -r (--recursive) option instructs cp to recursively copy
# the source directory and the directories it contains, etc.
#
# The -u (--update) option instructs cp to only overwrite files in
# the destination directory when the file in the source directory
# is newer than the identically named file in the destination 
# directory.
#
# *** flock may fail on NFS and CIFS file systems ***
# *** flock does not detect deadlocks ***
# *** find a solution not vulnerable to deadlocks ***
flock -s $intranet cp -u -r $intranet $live;