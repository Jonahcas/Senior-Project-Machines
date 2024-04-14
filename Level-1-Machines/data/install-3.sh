echo -e "\e[1;34m Updating repos \e[0m"reason
apt update

echo -e "\e[1;34m Installing Apache2 \e[0m"
apt install apache2 -y
Pictures
echo -e "\e[1;34m [+] Installing and configuring FTP \e[0m"
apt install vsftpd -y
ufw allow 20
ufw allow 21
mkdir /var/ftp
chown nobody:nogroup /var/ftp/
cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
sed -i 's/anonymous_enable=NO/anonymous_enable=YES/g' /etc/vsftpd.conf
# echo "anon_root=/var/ftp" >> /etc/vsftpd.conf - doesn't work for some reason
systemctl restart vsftpd

echo -e "\e[1;34m [+] Installing and configuring SSH \e[0m"
apt install openssh-server -y
ufw allow ssh

# add main user
echo -e "\e[1;34m [+] Adding Maugrim user \e[0m"
useradd -m Maugrim
echo 'Maugrim:w0lfsb@ne' | sudo chpasswd

# add folders and files
mkdir /home/Maugrim/Desktop
mkdir /home/Maugrim/Documents
mkdir /home/Maugrim/Downloads
mkdir /home/Maugrim/Pictures

# Installing SQL Server
echo -e "\e[1;34m [+] Installing MariaDB \e[0m"
apt install mariadb-server -y
if ! systemctl start mariadb; then
    echo "Error starting MariaDB"
    exit 1
fi
echo -e "\e[1;34m [+] Creating MariaDB Set-up... \e[0m"
DB_USER="Test"
DB_PASS="t3st_p@ss"
DB_NAME="TestDB"
TABLE_NAME="TestTable"
SQL_CREATE_USER="CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
SQL_GRANT_PRIVILEGES="GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'localhost';"
echo -e "\e[1;34m [+] Creating MariaDB User... \e[0m"
if ! mysql -e "$SQL_CREATE_USER"; then
    echo "Error creating user"
    exit 1
fi
echo -e "\e[1;34m [+] Granting Privileges... \e[0m"
if ! mysql -e "$SQL_GRANT_PRIVILEGES"; then
    echo "Error granting privileges"
    exit 1
fi
if ! mysql -e "FLUSH PRIVILEGES;"; then
    echo "Error flushing privileges"
    exit 1
fi
echo -e "\e[1;34m [+] Creating Database... \e[0m"
if ! mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"; then
    echo "Error creating database"
    exit 1
fi
echo -e "\e[1;34m [+] Creating Table... \e[0m"
if ! mysql -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $TABLE_NAME (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(255), PRIMARY KEY (id));"; then
    echo "Error creating table"
    exit 1
fi
echo -e "\e[1;34m [+] Inserting Data... \e[0m"
if ! mysql -e "USE $DB_NAME; INSERT INTO $TABLE_NAME (name) VALUES ('Test');"; then
    echo "Error inserting data"
    exit 1
fi
echo "Database setup completed successfully"

# clean up
echo -e "\e[1;34m [+] CLEANING UP... \e[0m"

echo "[+] Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/defaulthere/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
update-grub

echo "[+] Configuring hostname"
hostnamectl set-hostname Maugrim
cat << EOF > /etc/hosts
127.0.0.1 localhost
127.0.0.1 Maugrim
EOF

echo "[+] Disabling history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/Maugrim/.bash_history

echo "[+] Enabling root SSH login"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[+] Setting passwords"
echo "root:g0ld3nc0mp@ss" | sudo chpasswd

echo "[+] Cleaning up"
rm -rf /root/install.sh
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/Maugrim/.sudo_as_admin_successful
rm -rf /home/Maugrim/.cache
rm -rf /home/Maugrim/.viminfo
find /var/log -type f -exec sh -c "cat /dev/null > {}" \;