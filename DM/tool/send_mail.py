import smtplib
import win32com.client as win32
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr



def send_mail(msg):
    sender = 'test@qq.com' 
    receivers = ['test@qq.com']

    message = MIMEText(msg, 'plain', 'utf-8')
    message['From'] = formataddr(["Test mails", sender]) 
    message['To'] = ','.join(receivers) 

    subject = 'Test mails.'
    message['Subject'] = Header(subject, 'utf-8') 

    smtpObj = smtplib.SMTP('smtp.qq.com', port=25)
    smtpObj.login(user=sender, password='TEST')  
    smtpObj.sendmail(sender, receivers, message.as_string()) 


def send_mail_outlook_html(subject,receivers_list,msg,attachments = []):
    outlook = win32.Dispatch('outlook.application')
    mail = outlook.CreateItem(0)
    receivers = receivers_list
    mail.To = receivers[0]
    mail.Subject = subject
    mail.HTMLBody = msg
    for item in attachments: 
        mail.Attachments.Add(item) 
    mail.Send()
    