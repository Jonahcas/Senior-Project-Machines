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
echo -e "\e[1;34m [+] Adding Kirjava1 user \e[0m"
useradd -m Kirjava1
echo 'Kirjava1:5T@NF0RD' | sudo chpasswd

# add folders and files
mkdir /home/Kirjava1/Desktop
mkdir /home/Kirjava1/Documents
mkdir /home/Kirjava1/Documents/urgent
mkdir /home/Kirjava1/Downloads
mkdir /home/Kirjava1/Pictures

# add vulnerability
apt-get install telnetd -y
telnet localhost
echo "root:w1llparryth1s" >> /home/Kirjava1/Documents/urgent/credentials.txt
base64 /home/Kirjava1/Documents/urgent/credentials.txt > /home/Kirjava1/Documents/urgent/credentials2.txt
rm /home/Kirjava1/Documents/urgent/credentials.txt

# add LORE
echo "Configuration done; password encrypted." > /home/Kirjava1/Desktop/README.txt
echo "I've discovered a trail coming from outside the department. A company called CHOAM LLC made a deal with the boss. Thing is, I can't find anything about the deal beyond the planner note and when she clocked out. Maybe this is what Tr1@ge was looking for. Maybe he was right about what she wanted to do with his work..." > /home/Kirjava1/Desktop/text.txt
# clean up
echo -e "\e[1;34m [+] CLEANING UP... \e[0m"

echo "[+] Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/defaulthere/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
update-grub

echo "[+] Configuring hostname"
hostnamectl set-hostname Kirjava1
cat << EOF > /etc/hosts
127.0.0.1 localhost
127.0.0.1 Kirjava1
EOF

echo "[+] Disabling history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/Kirjava1/.bash_history

echo "[+] Enabling root SSH login"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[+] Setting passwords"
echo "root:w1llparryth1s" | sudo chpasswd

echo "[+] Cleaning up"
rm -rf /root/install.sh
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/Kirjava1/.sudo_as_admin_successful
rm -rf /home/Kirjava1/.cache
rm -rf /home/Kirjava1/.viminfo
find /var/log -type f -exec sh -c "cat /dev/null > {}" \;