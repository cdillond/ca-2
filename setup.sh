#! /bin/bash

# make sure this script is run with appropriate privileges.
if [ $(id -u) -ne 0 ]
then
    echo "ERROR: this script must be run as root or using sudo."
    exit 1
fi

admin_pw=$(cat admin_pw.txt)
# read the pw from a text file
if [ -z "$admin_pw" ]
then
    echo "ERROR: admin_pw.txt must exist and must contain a valid password."
    exit 1
fi

# create employees group
groupadd employees

# https://bugzilla.redhat.com/show_bug.cgi?id=2313559
# create admin user
useradd -p $admin_pw admin

# add admin to employees
usermod -a -G employees admin

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

intranet=/var/www/html/intranet
live=/var/www/html/live
mkdir $intranet $live


# I chose to store the intranet git repository separate from its working
# tree so as to avoid potential issues with employees who have rwx
# permissions on /var/www/html/intranet being able to delete the repo.
# it makes the permissions a little easier to manage. if the company wanted
# to allow employees to commit changes directly its location could be 
# changed to a shared directory. but, as it stands, the changes are being
# tracked by auditd, not git.
iPath=$ca2/intranet.git


# kind of an odd order of args
# all commands in the git-dir are relative to the work-tree
git --git-dir=$iPath --work-tree=$intranet init -b main
git clone -l $iPath $live


# adjust permissions
chmod 775 $intranet
 # prevent this from being accessed via httpd
chmod 770 $live/.git

# adjust ownership
chown -R admin:employees $intranet
chown -R admin $live
chown -R admin $ca2

# set audit watch rule for writes to $intranet
# originally had auditclt -w /var/www/html/intranet -p wa
# but this generated a warning stating that the "old style"
# of watch rule declarations are slower
auditctl -a exit,always -F dir=$intranet -F arch=$(uname -m) -F perm=wa

# update crontab to run the update script each night at 11
echo "0 23 * * * admin $ca2/update.sh" >> /etc/crontab

# update httpd to disallow access to  $live/.git
# this will already be prevented by the filesystem permissions
# but it will add redundancy and defense-in-depth.
# this does not affect the behavior observed by a visitor to
# the live website, but it results in a different message logged to
# /var/log/httpd/error_log when access attempts are made.
httpdCfg=/etc/httpd/conf/httpd.conf
echo "" >> $httpdCfg
echo "#" >> $httpdCfg
echo "# *** Added by ca-2 setup.sh ***" >> $httpdCfg
echo "#" >> $httpdCfg
echo "<Directory \"$live/.git\">" >> $httpdCfg
echo "AllowOverride None" >> $httpdCfg
echo "Require all denied" >> $httpdCfg
echo "</Directory>" >> $httpdCfg
echo "" >> $httpdCfg








