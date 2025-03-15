#! /bin/bash

cd /home/admin/ca-2/intranet.git
# bail early if there's an issue just because the script
# might be run from within another git repo, so the
# subsequent lines might have unintended effects.
if [ $? -ne 0 ]
then
    echo "ERROR: unable to access git repo"
    exit 1
fi
# stage all changes
git add .
git commit -m "daily commit $(date)"

# pull changes to live
cd /home/admin/ca-2/live.git
git pull origin main