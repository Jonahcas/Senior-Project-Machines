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
echo -e "\e[1;34m [+] Adding Test user \e[0m"
useradd -m Test
echo 'Test:t3st_p@ss' | sudo chpasswd

# add folders and files
mkdir /home/Test/Desktop
mkdir /home/Test/Documents
mkdir /home/Test/Downloads
mkdir /home/Test/Pictures
mkdir /home/Test/uploads
mkdir /var/www/html/photo-php

# testing commands - figure out how to make this work
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




# clean up
echo -e "\e[1;34m [+] CLEANING UP... \e[0m"

echo "[+] Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/defaulthere/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub
update-grub

echo "[+] Configuring hostname"
hostnamectl set-hostname Test
#cat <<EOF > /etc/hosts
#127.0.0.1 localhost
#127.0.0.1 Test
EOF

echo "[+] Disabling history files"
ln -sf /dev/null /root/.bash_history
ln -sf /dev/null /home/Test/.bash_history

echo "[+] Enabling root SSH login"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[+] Setting passwords"
echo "root:g0ld3nc0mp@ss" | sudo chpasswd

echo "[+] Cleaning up"
rm -rf /root/install.sh
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/Test/.sudo_as_admin_successful
rm -rf /home/Test/.cache
rm -rf /home/Test/.viminfo
find /var/log -type f -exec sh -c "cat /dev/null > {}" \;