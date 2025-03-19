#! /bin/bash

if [ $(id -u) -ne 0 ]
then
    echo "setup2.sh must be run with root privileges" >&2
    exit 1
fi

ca2=/home/admin/ca-2
# copy useful scripts to the admin's home directory.
mkdir -p $ca2
cp -r scripts $ca2/
# update group.sh to reflect the correct name of the apache daemon.
sed -i s/#%/programName=$1/ $ca2/scripts/group.sh
mv $ca2/scripts/menu.sh $ca2/menu.sh


# create the website's parent directory if it doesn't exist.
mkdir -p /var/www/html
# create directories for the intranet and live sites.
intranet=/var/www/html/intranet
live=/var/www/html/live
mkdir $intranet $live

# adjust permissions to allow employees to write to $intranet.
chmod 775 $intranet

# these dirs are currently owned by root; hand them over to admin.
chown -R admin:employees $intranet
chown -R admin $live
chown -R admin /home/admin

# set up the git repos as admin
runuser -u admin ./setup/setup3.sh $ca2 $intranet $live
status=$?
if [ $status -ne 0 ]
then
  exit $status
fi

# update crontab to run the update script each night at 2 am.
echo "0 2 * * * root $ca2/scripts/update.sh" >> /etc/crontab

# add a rule that instructs auditd to watch the intranet dir for writes and attribute modifications.
# initially this wasn't working because there was a default rule before it that disabled all subsequent rules
# currently just watching for writes, not attribute changes, to avoid cluttering the logs
echo "-w /var/www/html/intranet -p w -k audit-intranet" >> /etc/audit/rules.d/audit.rules

