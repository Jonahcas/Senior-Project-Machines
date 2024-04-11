import smtplib
import socket
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Email credentials and server information
smtp_server = "smtp.mail.yahoo.com"
port = 587
sender_email = "seniorproject2024@att.net"
password = "Th3R3cruiter!"

# Create a socket connection
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((smtp_server, port))

# Create an SMTP instance over the socket connection
server = smtplib.SMTP()
server.sock = sock

# Create a message
message = MIMEMultipart()
message["From"] = sender_email
message["To"] = "jcasablanca@stetson.edu"
message["Subject"] = "This is a test email."

# Add body to email
body = "This is a test email."
message.attach(MIMEText(body, "plain"))

try:
    # Connect to the server
    server.ehlo()
    print("Connected to the server")

    # Login to the email server
    #server.login(sender_email, password)
    #print("Logged into the server")

    # Send the email
    server.sendmail(sender_email, "casafam@bellsouth.net", message.as_string())

    print("Email sent successfully")

except Exception as e:
    print("An error occurred:", str(e))

finally:
    # Quit the server
    if 'server' in locals() and hasattr(server, 'sock') and server.sock is not None:
        server.quit()
        sock.close()  # Close the socket connection
