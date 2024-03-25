import subprocess
import smtplib
from email.mime.text import MIMEText
import socket

def send_email(email, subject, message):
    sender_email = "EDonald@gcc.recruitment.com"
    receiver_email = email
    smtp_server = "smtp.example.com"

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

message = "Test message."
subject = "Test subject."
if __name__ == "__main__":
    send_email('jcasablanca@stetson.edu', subject, message)

# export PS1="\u@\h \$(command here) $ " - put in Bash rc file to run when someone gets to root.
    # FIle should make a txt file, and if txt exists, don't run this again.