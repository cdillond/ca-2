#! /bin/bash

ca2=$1
intranet=$2
live=$3

cd $ca2
# update git settings for admin to avoid warnings later
gitCfg=/home/admin/.gitconfig
git config -f $gitCfg init.defaultBranch "main"
git config -f $gitCfg user.email "noreply@example.com" 
git config -f $gitCfg user.name "admin"


# I chose to store the intranet and live git repositories separately
# from their working trees. This is mainly to make managing permissions
# simpler. Members of the employees group need rwx permissions for the
# intranet directory. If the git repo were to be stored in its default location,
# any employee could delete and replace it, even without write access
# to the .git directory. Keeping the repos separate also hides them from
# the http server. I don't want the repos to be accessible by http clients,
# and storing them in the admin's home directory means that there's 1) no
# need to worry about making sure the permissions are always correct and 2) no 
# need to update the httpd config to prevent access to them.
intranetGit=$ca2/intranet.git
liveGit=$ca2/live.git

git --git-dir=$intranetGit --work-tree=$intranet init
status=$?
if [ $status -ne 0 ]
then
  exit $status
fi

git --git-dir=$liveGit --work-tree=$live init
status=$?
if [ $status -ne 0 ]
then
  exit $status
fi

cd $liveGit
git remote add origin $intranetGit
exit $?
