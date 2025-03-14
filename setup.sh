#! /bin/bash
# record the cwd for later
here=$(pwd)
echo $here
# create employees group
groupadd employees
# create admin user
useradd -p PASSWORD admin
# add admin to employees
usermod -a -G employees admin

mkdir -p /var/www/html
# most paths hereafter will be relative
cd /var/www/html

# makes a new dir named intranet and inits a git repo there
git init -b main intranet
# clone ./intranet to ./live
git clone -l intranet live

# update permissions to drw-rw-r--
chmod 775 live
chmod 770 live/.git
# change owner of the live directory to admin
# the group can stay as root
chown -R admin live


# ofc the git repo could be deleted from the dir, but not written
chmod 775 intranet
# prevent employees from messing with the git repo
chmod 770 intranet/.git # shouldn't be readable by employees i think
# recursively change the owner of intranet to admin
# this should affect intranet/.git, which should not be editable
# by employees
chown -R admin intranet
# change the group of intranet to employees, but not recursively
chown :employees intranet

mkdir -p /home/admin/ca-2
cp -p $here/copy_new.sh /home/admin/ca-2/copy_new.sh
chown -R admin:admin /home/admin/ca-2
chmod u+x /home/admin/ca-2/copy_new.sh










