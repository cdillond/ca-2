#! /bin/bash

# The name of the group of the system user running the apache
# web server can change at runtime depending on the server's configuration.
# On Debian/Ubuntu, this value is defined in /etc/apache2/envvars. On Fedora,
# it can be found in /etc/httpd/conf/httpd.conf.
#
# To query the server for this information, the name of the program provided
# by the server for controlling the server's systemd service needs to be known
# at setup time. On Fedora, it is installed as "httpd". On Ubuntu, it's "apache2ctl". 
#
# This information is only really relevant to ensure that the server has
# continued access to the intranet directory while the site is undergoing
# a backup. If the necessary information cannot be determined,
# this script returns the group "admin", which will result in the server losing
# access to the intranet directory during backups, but won't have any other effects.

# *** TO BE REPLACED WITH programName BY setup.sh ***
#%

groupName=""
if [ -v $programName ]
then
    # The line we're looking for should read something like 'Group: name="apache" id=48 not_used'
    # The awk statement sets the delimeter to to '"' and then prints the second field of the line
    # that includes /Group:/. In this case, $1 == "Group: name=" ($0 is the entire line).
    groupName="$($programName -S | awk -F'"' '/Group:/ { print $2 }')"
fi

if [ -n "$groupName" ]
then
    groupName=admin
fi

echo "$groupName"