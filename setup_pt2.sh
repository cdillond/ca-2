#! /bin/bash

if [ $(id -u) -ne 0 ]
then
    echo "setup_pt2.sh must be run with root privileges" >&2
    exit 1
fi

ca2=/home/admin/ca-2
# copy useful scripts to the admin's home directory
mkdir -p $ca2
cp scripts $ca/scripts
mv $ca/scripts/menu.sh $ca/menu.sh


# create the website's parent directory if it doesn't exist
mkdir -p /var/www/html
# create directories for the intranet and live sites
intranet=/var/www/html/intranet
live=/var/www/html/live
mkdir $intranet $live

# adjust permissions
chmod 775 $intranet

# adjust ownership
chown -R admin:employees $intranet
chown -R admin $live
chown -R admin $ca2

# set up the git repos as admin
runuser -u admin ./setup_git.sh $ca2 $intranet $live

# update crontab to run the update script each night at 2 am
echo "0 2 * * * root $ca2/scripts/update.sh" >> /etc/crontab

# add a rule that instructs auditd to watch the intranet dir for writes and attribute modifications.
# initially this wasn't working because there was a default rule before it that disabled all subsequent rules
echo "-w /var/www/html/intranet -p wa -k watch-intranet" >> /etc/audit/rules.d/audit.rules