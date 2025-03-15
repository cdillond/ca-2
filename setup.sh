#! /bin/bash

# make sure this script is run with appropriate privileges.
if [ $(id -u) -ne 0 ]
then
    echo "ERROR: this script must be run as root or using sudo."
    exit 1
fi

# create employees group
groupadd employees
if [ $? -ne 0 ] 
then
    echo "ERROR: this script should only be run once!"
    exit 1
fi

# create admin user as a member of employees
useradd admin -G employees
if [ $? -ne 0 ]
then
    echo "ERROR: problem adding admin."
    exit 1
fi

# to finalize the setup of admin, the user needs to be 
# given a password and sudo privileges
# i'm not including it here because it's different on
# Fedora and Ubuntu


ca2=/home/admin/ca-2
# copy useful scripts to the admin's home directory
mkdir $ca2
cp update.sh $ca2/
cp report.sh $ca2/
cp menu.sh $ca2/


# update git settings for admin to avoid warnings later
gitCfg=/home/admin/.gitconfig
git config -f $gitCfg init.defaultBranch "main"
git config -f $gitCfg user.email "admin@tudblin.ie" 
git config -f $gitCfg user.name "admin"

# create the website's parent directory if it doesn't exist
mkdir -p /var/www/html
# create directories for the intranet and live sites
intranet=/var/www/html/intranet
live=/var/www/html/live
mkdir $intranet $live


# I chose to store the intranet and live git repositories separately
# from their working trees. This is mainly to make managing permissions
# simpler. Members of the employees group need rwx permissions for the
# intranet directory. If the git repo were to be stored in its default location,
# any employee could delete and replace it, even without write access
# to the .git directory. Keeping the repos separate also hides them from
# the http server. I don't want the repos to be accessible by http clients,
# and storing them in the admin's home directory means that there's no need
# 1) worry about making sure the permissions are always correct and 2) update
# the httpd config to prevent access to them.
intranetGit=$ca2/intranet.git
liveGit=$ca2/live.git
git --git-dir=$intranetGit --work-tree=$intranet init -b main
git --git-dir=$liveGit --work-tree=$live init -b main
cd $liveGit
git remote add origin $intranetGit


# adjust permissions
chmod 775 $intranet

# adjust ownership
chown -R admin:employees $intranet
chown -R admin $live
chown -R admin $ca2

# update crontab to run the update script each night at 11
echo "0 23 * * * admin $ca2/update.sh" >> /etc/crontab

# add a rule that instructs auditd to watch the intranet dir for writes and attribute modifications.
# I originally had this as "auditctl -w /var/www/html/intranet -p wa" but it generated a warning
# about "old style" rules being slower.
# echo "-a always,exit -F arch=$(uname -m) -F dir=$intranet -F perm=wa -k intranet_changes" >> /etc/audit/rules.d/audit.rules
echo "-w /var/www/html/intranet -p wa -k watch-intranet" >> /etc/audit/rules.d/audit.rules







