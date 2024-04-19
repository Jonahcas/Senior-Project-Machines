import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from dotenv import load_dotenv

load_dotenv()

message = Mail(
    from_email='seniorproject2024@att.net',
    to_emails='jcasablanca@stetson.edu',
    subject='Sending test email with python and Twilio-sendgrid API',
    html_content='<strong>Thank you for your business</strong>')
try:
    sg = SendGridAPIClient(os.environ.get('SENDGRID_API_KEY'))
    response = sg.send(message)
    print(response.status_code)
    print(response.body)
    print(response.headers)
except Exception as e:
    print(str(e))