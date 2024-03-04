# user password: 5T@NF0RD

echo -e "\e[1;34m Updating repos \e[0m"
apt update

echo -e "\e[1;34m Installing Apache2 \e[0m"
apt install apache2 -y

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
echo -e "\e[1;34m [+] Adding Kirjava user \e[0m"
useradd -m Kirjava
echo 'Kirjava:5T@NF0RD' | sudo chpasswd

# add folders and files
mkdir /home/Kirjava/Desktop
mkdir /home/Kirjava/Documents
mkdir /home/Kirjava/Downloads
mkdir /home/Kirjava/Pictures

# clean up
echo -e "\e[1;34m [+] CLEANING UP... \e[0m"

echo "[+] Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/defaulthere/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
update-grub

echo "[+] Configuring hostname"
hostnamectl set-hostname Kirjava
cat << EOF > /etc/hosts
127.0.0.1 localhost
127.0.0.1 Kirjava
EOF

echo "[+] Disabling history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/Kirjava/.bash_history

echo "[+] Enabling root SSH login"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[+] Setting passwords"
echo "root:w1llparryth1s" | sudo chpasswd

echo "[+] Cleaning up"
rm -rf /root/install.sh
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/Kirjava/.sudo_as_admin_successful
rm -rf /home/Kirjava/.cache
rm -rf /home/Kirjava/.viminfo
find /var/log -type f -exec sh -c "cat /dev/null > {}" \;