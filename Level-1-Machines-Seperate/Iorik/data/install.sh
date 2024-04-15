#!/bin/bash
echo -e "\e[1;34m Updating repos \e[0m"
apt update -y

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

# allowing port 80
echo -e "\e[1;34m [+] Allowing port 80 \e[0m"
ufw allow 80

# add main user
echo -e "\e[1;34m [+] Adding Iorik1 user \e[0m"
useradd -m Iorik1
echo 'Iorik1:t3st_p@ss' | sudo chpasswd

# add folders and files
mkdir /home/Iorik1/Desktop
mkdir /home/Iorik1/Documents
mkdir /home/Iorik1/Downloads
mkdir /home/Iorik1/Pictures

echo -e "Fornsworth notes:\n- Contact A. Fornsworth about the vulnerability, schedule time to remote-in.
        \n- Log vulnerability for ticket. \n\n
        Jacobson notes:\n- Contact B. Jacobson about OS Glitch updates.
        \n- Log and file for Pan to look at." > /home/Iorik/Desktop/Client_Notes/notes.txt

# add vulnerability - insecure CRON job
echo -e "#!/bin/bash\n echo "Current Date and Time: $(date)"" > /home/Iorik/Downloads/misc/script.sh
chmod +x /home/Iorik/Downloads/misc/script.sh
chmod +w /home/Iorik/Downloads/misc/script.sh
chmod -w /home/Iorik/Downloads/misc
crontab -e
echo "*/15 * * * * /home/Iorik/Downloads/misc/script.sh > /dev/null 2>&1" | crontab -u Iorik -


# clean up
echo -e "\e[1;34m [+] CLEANING UP... \e[0m"

echo "[+] Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/defaulthere/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
update-grub

echo "[+] Configuring hostname"
hostnamectl set-hostname Iorik1
#cat <<EOF > /etc/hosts
#127.0.0.1 localhost
#127.0.0.1 Iorik1
EOF

echo "[+] Disabling history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/Iorik1/.bash_history

echo "[+] Enabling root SSH login"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[+] Setting passwords"
echo "root:g0ld3nc0mp@ss" | sudo chpasswd

echo "[+] Cleaning up"
rm -rf /root/install.sh
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/Iorik1/.sudo_as_admin_successful
rm -rf /home/Iorik1/.cache
rm -rf /home/Iorik1/.viminfo
find /var/log -type f -exec sh -c "cat /dev/null > {}" \;