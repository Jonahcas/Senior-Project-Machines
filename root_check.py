import subprocess
import smtplib
from email.mime.text import MIMEText
import socket

def send_email(subject, message):
    sender_email = ""
    receiver_email = ""
    smtp_server = ""

    msg = MIMEText(message)
    msg["Subject"] = subject
    msg["From"] = sender_email
    msg["To"] = receiver_email

    with smtplib.SMTP(smtp_server) as server:
        server.send_message(msg)

def check_root():
    hostname = socket.gethostname()

    command = f"grep 'su: pam_unix(su-1:session):session opened for user root' /var/log/auth.log"
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if result.stdout:
        send_email(f"Root Access Detected on {hostname}", "Root access has been detected on the server.")

if __name__ == "__main__":
    check_root()