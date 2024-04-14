#!/bin/expect -f
apt-get install -y expect
root_password="r00tp@ss"
set timeout 10
spawn mysql_secure_installation
expect "Enter current password for root \(enter for none\):"
send "\r"
expect "Change the root password\?"
send "Y\r"
expect "New password:"
send "$root_password\r"
expect "Re-enter new password:"
send "$root_password\r"
expect "Remove anonymous users\?"
send "Y\r"
expect "Disallow root login remotely\?"
send "n\r"
expect "Remove test database and access to it\?"
send "Y\r"
expect "Reload privilege tables now\?"
send "Y\r"
