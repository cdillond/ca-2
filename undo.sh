#! /bin/bash
# *** potentially very risky *** 
# *** config files still need to be manually reverted ***
sudo userdel -r admin
sudo groupdel employees
sudo rm -rf /var/www/html/intranet
sudo rm -rf /var/www/html/live

sudoedit /etc/crontab
sudoedit /etc/audit/rules.d/audit.rules
