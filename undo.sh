#! /bin/bash
# *** potentially very risky *** 
# *** config files still need to be manually reverted ***
userdel admin
groupdel employees
rm -rf /home/admin
rm -rf /var/mail/admin
rm -rf /var/www/html/intranet
rm -rf /var/www/html/live
echo "remember to undo changes to /etc/crontab"
echo "remember to undo changes to /etc/audit/rules.d/audit.rules"