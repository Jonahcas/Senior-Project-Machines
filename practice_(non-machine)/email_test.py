import base64
import socket
from ssl import SSLContext
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Email credentials and server information
smtp_server = "smtp.mail.yahoo.com"
port = 587
sender_email = "seniorproject2024@att.net"
password = "Th3R3cruiter!"

# Create a message
message = MIMEMultipart()
message["From"] = sender_email
message["To"] = "casafam@bellsouth.net"
message["Subject"] = "Test email"

# Add body to email
body = "This is a test email."
message.attach(MIMEText(body, "plain"))

try:
    # Create a socket object
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Connect to the server
    client_socket.connect((smtp_server, port))
    print("Connected to the server")

    # Receive the server's response
    response = client_socket.recv(1024)
    print(response.decode())

    # Send EHLO command
    client_socket.sendall(b'EHLO example.com\r\n')
    response = client_socket.recv(1024)
    print(response.decode())

    # Start TLS
    client_socket.sendall(b'STARTTLS\r\n')
    response = client_socket.recv(1024)
    print(response.decode())

    # Start TLS negotiation
    client_socket = socket.create_connection((smtp_server, port))
    client_socket = ssl.SSLContext.wrap_socket(client_socket)
    print("TLS connection established")

    # Login to the email server
    client_socket.sendall(b'AUTH LOGIN\r\n')
    response = client_socket.recv(1024)
    print(response.decode())

    client_socket.sendall(base64.b64encode(sender_email.encode()) + b'\r\n')
    response = client_socket.recv(1024)
    print(response.decode())

    client_socket.sendall(base64.b64encode(password.encode()) + b'\r\n')
    response = client_socket.recv(1024)
    print(response.decode())

    # Send the email
    client_socket.sendall(b'MAIL FROM:<' + sender_email.encode() + b'>\r\n')
    response = client_socket.recv(1024)
    print(response.decode())

    client_socket.sendall(b'RCPT TO:<casafam@bellsouth.net>\r\n')
    response = client_socket.recv(1024)
    print(response.decode())

    client_socket.sendall(b'DATA\r\n')
    response = client_socket.recv(1024)
    print(response.decode())

    client_socket.sendall(b'Subject: Test email\r\n\r\n')
    client_socket.sendall(b'This is a test email.\r\n')
    client_socket.sendall(b'.\r\n')

    response = client_socket.recv(1024)
    print(response.decode())

    print("Email sent successfully")

except Exception as e:
    print("An error occurred:", str(e))

finally:
    # Close the socket when done
    if 'client_socket' in locals():
        client_socket.close()
