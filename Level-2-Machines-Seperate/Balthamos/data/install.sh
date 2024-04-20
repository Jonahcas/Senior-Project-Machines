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
echo -e "\e[1;34m [+] Adding Balthamos1 user \e[0m"
useradd -m Balthamos1
echo 'Balthamos1:b@ruch' | sudo chpasswd

# add folders and files
mkdir /home/Balthamos1/Desktop
mkdir /home/Balthamos1/Documents
mkdir /home/Balthamos1/Downloads
mkdir /home/Balthamos1/Pictures

echo -e "\e[1;34m [+] Installing Player-To-User Vulnerability \e[0m"
apt install php -y
echo "<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Photo Upload</title>
</head>
<body>
    <h2>Upload Photo</h2>
    <form action="upload.php" method="post" enctype="multipart/form-data">
        <input type="file" name="file">
        <input type="submit" value="Upload">
    </form>
</body>
</html>" > /var/www/html/photo-php/index.php

echo "<?php\n
// Check if the form was submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Check if file was uploaded without errors
    if (isset($_FILES["file"]) && $_FILES["file"]["error"] == 0) {
        $uploadDir = "uploads/"; // Directory where files will be uploaded
        $filename = basename($_FILES["file"]["name"]);
        $targetPath = $uploadDir . $filename;
        
        // Move the uploaded file to the destination directory
        if (move_uploaded_file($_FILES["file"]["tmp_name"], $targetPath)) {
            // File uploaded successfully
            // Redirect to the uploaded image
            header("Location: $targetPath");
            exit();
        } else {
            // Error while uploading file
            echo "Sorry, there was an error uploading your file.";
        }
    } else {
        // No file uploaded or file upload error occurred
        echo "Please select a file to upload.";
    }
}
?>" > /var/www/html/photo-php/upload.php
chown -R www-data:www-data /var/www/html/photo-php
chmod -R 755 /var/www/html/photo-php


# Install necessary packages
echo -e "\e[1;34m [+] Installing SMB \e[0m"
sudo apt install -y samba
# Create a directory to share
echo -e "\e[1;34m [+] Creating SMB share \e[0m"
sudo mkdir -p /srv/balthamos_share
sudo chmod -R 777 /srv/balthamos_share
# Configure Samba
echo -e "\e[1;34m [+] Configuring SMB \e[0m"
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak   # Backup the original smb.conf file
sudo bash -c 'cat <<EOT >> /etc/samba/smb.conf
[balthamos_share]
   comment = Balthamos1 SMB Share
   path = /srv/balthamos_share
   browseable = yes
   read only = no
   guest ok = yes
   create mask = 0777
   directory mask = 0777
EOT'
# Restart Samba service
echo -e "\e[1;34m [+] Restarting SMB service \e[0m"
sudo systemctl restart smbd
echo "SMB share has been created."
# Creating data for the share
echo -e "\e[1;34m [+] Creating data for the SMB share \e[0m"
echo "user:root password:g0ld3nc0mp@ss\n user:balthamos password:b@ruch" > data.txt

# SMBclient check
check_smbclient() {
    if ! command -v smbclient &> /dev/null;then
        echo -e "\e[1;34m [+] Installing smbclient \e[0m"
        apt install smbclient -y
    fi
}

# Access share
access_share() {
    if ! smbclient //localhost/balthamos_share -U guest -c "$1";then
        echo -e "\e[1;31m [!] Failed to access share \e[0m"
        exit 1
    fi
}

check_smbclient

access_share "ls"
access_share "put data.txt"


# clean up
echo -e "\e[1;34m [+] CLEANING UP... \e[0m"

echo "[+] Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/defaulthere/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
update-grub

echo "[+] Configuring hostname"
hostnamectl set-hostname Balthamos1
cat << EOF > /etc/hosts
127.0.0.1 localhost
127.0.0.1 Balthamos1
EOF

echo "[+] Disabling history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/Balthamos1/.bash_history

echo "[+] Enabling root SSH login"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[+] Setting passwords"
echo "root:g0ld3nc0mp@ss" | sudo chpasswd

echo "[+] Cleaning up"
rm -rf /root/install.sh
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/Balthamos1/.sudo_as_admin_successful
rm -rf /home/Balthamos1/.cache
rm -rf /home/Balthamos1/.viminfo
find /var/log -type f -exec sh -c "cat /dev/null > {}" \;