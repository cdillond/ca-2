#! /bin/bash

cd /home/admin/ca-2/intranet.git
# stage all changes
git add .
git commit -m "daily commit $(date)"

# pull changes to live
cd /var/www/html/live
git pull