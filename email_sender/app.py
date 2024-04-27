import os
from os.path import join, dirname
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from dotenv import load_dotenv

dotenv_path = join(dirname(__file__), 'sendgrid.env')
load_dotenv(dotenv_path)

num_env_vars = len(os.environ)
print(f"Number of environment variables: {num_env_vars}")

for key, value in os.environ.items():
    print(f"{key}: {value}")

num_env_vars_after = len(os.environ)
print('\n'+f"Number of environment variables after printing vars: {num_env_vars_after}")


message = Mail(
    from_email='seniorproject2024@att.net',
    to_emails='jcasablanca@stetson.edu',
    subject='This is another test email',
    html_content='<strong>This is the second email I have sent</strong>')
try:
    print(os.environ.get('SENDGRID_API_KEY'))
    sg = SendGridAPIClient(os.environ.get('SENDGRID_API_KEY'))
    response = sg.send(message)
    print(response.status_code)
    print(response.body)
    print(response.headers)
except Exception as e:
    print(str(e))