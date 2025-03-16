#! /bin/bash

# create employees group
sudo groupadd employees
status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: problem adding employees group." >&2
    exit $status
fi

# create admin user as a member of employees
# this prints out an error message on Fedora but succeeds anyway (related: https://bugzilla.redhat.com/show_bug.cgi?id=2313559)
sudo useradd -G employees admin
status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: problem adding admin user." >&2
    exit status
fi

# this requires user interaction
echo "set the password for the admin user"
sudo passwd admin
status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: problem setting admin password." >&2
    exit $status
fi

# this may require user interaction
if [ ! -z "$(grep fedora /etc/os-release)" ]
then
    sudo usermod -a -G wheel admin
elif [ ! -z "$(grep -e ubuntu -e debian /etc/os-release)" ]
then
    sudo usermod -a -G sudo admin
else
    echo "enter sudo group name (e.g. wheel on Fedora or sudo on Ubuntu)"
    read sudoers
    sudo usermod -a -G $sudoers admin
fi

# this can be manually fixed later if it happens.
if [ $? -ne 0 ]
then
    echo "ERROR: admin not added to sudoers" >&2
fi


# run the entirety of setup2.sh as superuser
sudo ./setup/setup2.sh
status=$?
if [ $status -ne 0 ]
then
  exit $status
fi

echo "updates have been applied to /etc/crontab and /etc/audit/rules.d/audit.rules"
echo "do you wish to make additional changes to /etc/crontab? [y/n]"
read confirm
if [ $confirm = "y" ]
then
    sudoedit /etc/crontab
fi

echo "do you wish to confirm changes made to /etc/audit/rules.d/audit.rules? [y/n]"
read confirm
if [ $confirm = "y" ]
then
    sudoedit /etc/audit/rules.d/audit.rules
fi

echo "restart your computer for all changes to take effect"
