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
file_name="logins.txt"
file_name_2="logins.txt.b64"
text_context="B0ard1:P@rac3lsus
B0@rd2:Parad1s0
B0@rd3: G3pp3tt0"

# Base64 encode the file
base64 "$file_name" > "$file_name_2"

# move file
mv logins.txt.b64 ../../

# Put the file into the ftp server
ftp -n localhost <<EOF
quote USER Xaphania
quote PASS p0l@r15
cd ../../
put logins.txt.b64
bye
EOF

# Create Samba User
useradd -m B0ard1
echo 'B0ard1:P@rac3lsus' | sudo chpasswd

# Install necessary packages
echo -e "\e[1;34m [+] Installing SMB \e[0m"
sudo apt install -y samba

# Stuff goes here
addgroup smbgrp
usermod -aG smbgrp B0ard1
usermod -aG smbgrp Xaphania
sudo tee -a /etc/samba/smb.conf << EOT
[admin_share$]
    path = /
    browsable = yes
    guest ok = no
    valid users = @smbgrp
    read only = no
EOT


# SMBclient check
check_smbclient() {
    if ! command -v smbclient &> /dev/null;then
        echo -e "\e[1;34m [+] Installing smbclient \e[0m"
        apt install smbclient -y
    fi
}

# Access share
access_share() {
    if ! smbclient //localhost/ -U guest -c "$1";then
        echo -e "\e[1;31m [!] Failed to access share \e[0m"
        exit 1
    fi
}

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