import os
from os.path import join, dirname
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from dotenv import load_dotenv

def change_encoding(input_file, output_file, current_encoding, target_encoding):
    # Read the content of the input file with the current encoding
    with open(input_file, 'r', encoding=current_encoding) as f:
        content = f.read()
    # Encode the content with the target encoding
    encoded_content = content.encode(target_encoding)
    # Write the encoded content to the output file with the target encoding
    with open(output_file, 'wb') as f:
        f.write(encoded_content)

# Define the input and output file paths
input_file = 'sendgrid.env'
output_file = 'sendgrid_encoded.env'
# Define the current and target encodings
current_encoding = 'utf-16-le'
target_encoding = 'utf-8'
# Change the encoding of the input file
change_encoding(input_file, output_file, current_encoding, target_encoding)

dotenv_path = join(dirname(__file__), 'sendgrid_encoded.env')
load_dotenv(dotenv_path)

#for key, value in os.environ.items():
#    print(f"{key}: {value}")

message = Mail(
    from_email='seniorproject2024@att.net',
    to_emails='jcasablanca@stetson.edu',
    subject='Sending test email with python and Twilio-sendgrid API',
    html_content='<strong>Thank you for your business</strong>')
try:
    print(os.environ.get('SENDGRID_API_KEY'))
    sg = SendGridAPIClient(os.environ.get('SENDGRID_API_KEY'))
    response = sg.send(message)
    print(response.status_code)
    print(response.body)
    print(response.headers)
except Exception as e:
    print(str(e))