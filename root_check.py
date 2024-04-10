import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Email credentials and server information
smtp_server = "smtp.mail.yahoo.com"
port = 587
sender_email = "seniorproject2024@att.net"
password = "Th3R3cruiter!"

server = smtplib.SMTP(smtp_server, port)
# server.connect(smtp_server, port)

# Create a message
message = MIMEMultipart()
message["From"] = sender_email
message["To"] = "jcasablanca@stetson.edu"
message["Subject"] = "Test email"

# Add body to email
body = "This is a test email."
message.attach(MIMEText(body, "plain"))

try:
    # Connect to the server
    server.ehlo()
    server.starttls()
    print("Connected to the server")

    # Login to the email server
    server.login(sender_email, password)
    print("Logged into the server")

    # Send the email
    server.sendmail(sender_email, "jcasablanca@stetson.edu", message.as_string())

    print("Email sent successfully")

except Exception as e:
    print("An error occurred:", str(e))

finally:
    # Quit the server
    if 'server' in locals() and hasattr(server, 'sock') and server.sock is not None:
        server.quit()


'''def send_email(email, subject, message):
    sender_email = "EDonald@gcc.recruitment.com"
    receiver_email = email
    smtp_server = "smtp.example.com"

    msg = MIMEText(message)
    msg["Subject"] = subject
    msg["From"] = sender_email
    msg["To"] = receiver_email

    with smtplib.SMTP(smtp_server) as server:
        server.send_message(msg)
'''

# export PS1="\u@\h \$(command here) $ " - put in Bash rc file to run when someone gets to root.
    # FIle should make a txt file, and if txt exists, don't run this again.

'''def check_root():
    hostname = socket.gethostname()

    command = f"grep 'su: pam_unix(su-1:session):session opened for user root' /var/log/auth.log"
    result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if result.stdout:
        send_email(f"Root Access Detected on {hostname}", "Root access has been detected on the server.")

message = "Test message."
subject = "Test subject."
if __name__ == "__main__":
    send_email('jcasablanca@stetson.edu', subject, message)'''