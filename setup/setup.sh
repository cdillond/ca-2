#! /bin/bash

# create employees group.
sudo groupadd employees
status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: problem adding employees group." >&2
    exit $status
fi

# create admin user as a member of employees.
# this prints out an error message on Fedora but succeeds anyway. (related: https://bugzilla.redhat.com/show_bug.cgi?id=2313559)
sudo useradd -G employees admin
status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: problem adding admin user." >&2
    exit $status
fi

echo "**********"
echo "set the password for the admin user"
sudo passwd admin
status=$?
if [ $status -ne 0 ]
then
    echo "ERROR: problem setting admin password." >&2
    exit $status
fi


# add admin to sudoers; the specific group depends on the distro.
# first check if it can be done automatically, then fall back to manual.
status=1
if [ ! -z "$(grep fedora /etc/os-release)" ]
then
    sudo usermod -a -G wheel admin
    status=$?
elif [ ! -z "$(grep -e ubuntu -e debian /etc/os-release)" ]
then
    sudo usermod -a -G sudo admin
    status=$?
fi

if [ $status -ne 0 ]
then
    echo "**********"
    read -p "enter sudo group name (e.g. wheel on Fedora or sudo on Ubuntu): " sudoers
    sudo usermod -a -G $sudoers admin
    status=$?
fi

# this can be fixed later.
if [ $status -ne 0 ]
then
    echo "ERROR: admin not added to sudoers" >&2
fi


# run the entirety of setup2.sh as superuser.
sudo ./setup/setup2.sh
status=$?
if [ $status -ne 0 ]
then
  exit $status
fi

echo "**********"
echo "updates have been applied to /etc/crontab and /etc/audit/rules.d/audit.rules"
read -p "do you wish to make additional changes to /etc/crontab? [y/n] " confirm
if [ $confirm = "y" ]
then
    sudoedit /etc/crontab
fi
echo "**********"
read -p "do you wish to confirm changes made to /etc/audit/rules.d/audit.rules? [y/n] " confirm
if [ $confirm = "y" ]
then
    sudoedit /etc/audit/rules.d/audit.rules
fi
echo "**********"
echo "restart your computer for all changes to take effect"
