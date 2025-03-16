#! /bin/bash

# create employees group
sudo groupadd employees
if [ $? -ne 0 ]
then
    echo "ERROR: problem adding employees group." >&2
    exit 1
fi

# create admin user as a member of employees
# this prints out an error message on Fedora but succeeds anyway (related: https://bugzilla.redhat.com/show_bug.cgi?id=2313559)
sudo useradd -G employees admin
if [ $? -ne 0 ]
then
    echo "ERROR: problem adding admin user." >&2
    exit 1
fi

# this requires user interaction
echo "set the password for the admin user"
sudo passwd admin

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

# add the current user to the employees group
# self=$(whoami)
# sudo usermod -a -G employees $self

# run the remainder of the setup process as root, no interaction needed
sudo ./setup_pt2.sh








