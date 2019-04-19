
# coding:utf-8
import smtplib
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr

def send_mail(msg):
    sender = 'toliuzp@qq.com' 
    #receivers = ('zongpei.liu@aspiraconnect.com')
    #receivers = ['zongpei.liu@aspiraconnect.com','Tom.Xie@aspiraconnect.com','Gary.Zhou@aspiraconnect.com','Tim.Wang@aspiraconnect.com']
    receivers = ['zongpei.liu@aspiraconnect.com','toliuzp@qq.com']


    message = MIMEText(msg, 'plain', 'utf-8')
    message['From'] = formataddr(["ETL loading Abnormal", sender]) 
    message['To'] = ','.join(receivers) 

    subject = 'Prod ETL loading monitor.'
    message['Subject'] = Header(subject, 'utf-8') 

    smtpObj = smtplib.SMTP('smtp.qq.com', port=25)
    smtpObj.login(user=sender, password='ngccushxiemjbjef')  
    smtpObj.sendmail(sender, receivers, message.as_string()) 