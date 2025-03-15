#! /bin/bash
# *** potentially risky *** 
# *** crontab still needs to be manually edited ***
userdel admin
groupdel employees
rm -rf /home/admin
rm -rf /var/mail/admin
rm -rf /var/www/html/intranet
rm -rf /var/www/html/live