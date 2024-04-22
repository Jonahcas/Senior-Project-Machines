echo -e "\e[1;34m Updating repos \e[0m"reason
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
echo -e "\e[1;34m [+] Adding Xaphania user \e[0m"
useradd -m Xaphania
echo 'Xaphania:p0l@r15' | sudo chpasswd

# add folders and files
mkdir /home/Xaphania/Desktop
mkdir /home/Xaphania/Documents
mkdir /home/Xaphania/Downloads
mkdir /home/Xaphania/Pictures

# Create a file with several usernames and passwords, and put it in /var/ftp/logins.txt
cat << EOF > /var/ftp/logins.txt
B0ard1:P@rac3lsus
B0@rd2:Parad1s0
B0@rd3: G3pp3tt0
EOF

# Base64 encode the file
base64 /var/ftp/logins.txt > /var/ftp/logins.txt.b64

# Put the file into the ftp server
ftp -n localhost <<END_SCRIPT
quote USER anonymous
quote PASS anonymous
binary
cd /var/ftp
put /var/ftp/logins.txt.b64
quit
END_SCRIPT

# clean up
echo -e "\e[1;34m [+] CLEANING UP... \e[0m"

echo "[+] Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/defaulthere/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
update-grub

echo "[+] Configuring hostname"
hostnamectl set-hostname Xaphania
cat << EOF > /etc/hosts
127.0.0.1 localhost
127.0.0.1 Xaphania
EOF

echo "[+] Disabling history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/Xaphania/.bash_history

echo "[+] Enabling root SSH login"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[+] Setting passwords"
echo "root:g0ld3nc0mp@ss" | sudo chpasswd

echo "[+] Cleaning up"
rm -rf /root/install.sh
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/Xaphania/.sudo_as_admin_successful
rm -rf /home/Xaphania/.cache
rm -rf /home/Xaphania/.viminfo
find /var/log -type f -exec sh -c "cat /dev/null > {}" \;