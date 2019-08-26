###
#  monitor Focus Migration target table
#  determine if the changes impact Mart
#  TODO: add re_name and drop monitor.
###

import pandas as pd
import datetime
from openpyxl import Workbook
from openpyxl import load_workbook
import os
import sys
sys.path.append(os.getcwd())

import conf.acct_focus as acct
from db_connect.sqlserver_db import UseSqlserverDB, query_first_value, has_data, query, execute
from tool.tool import logger
from tool.send_mail import send_mail_outlook_html as mail
from tool.TSQL import query_meta_data
pd.set_option('max_colwidth',-1)

MINITOR_TABLE_LIST = [
'ActiveOutdoorsTransaction',
'Address2',
'AddressDetail',
'Agent',
'AgentApplication',
'AgentBankAccount',
'AgentOutletApplicationOutlet',
'AgentOwnership',
'ChildSupport',
'ChildSupportAnswer',
'Customer',
'CustomerBusiness',
'CustomerBusinessOwnership',
'CustomerDisability',
'CustomerHunterEd',
'CustomerIdentity',
'CustomerIndividual',
'CustomerQualification',
'CustomerQualificationFarmerCertification',
'CustomerRestriction',
'CustomerRestrictionDetail',
'Document',
'DocumentDetail',
'DrawTicket',
'DrawTicketHuntChoice',
'FeeGroup',
'Hunt',
'HuntApplication',
'HuntApplicationLicense',
'HuntSeason',
'HuntSeasonHunt',
'HuntTypeLicenseYear',
'Item',
'ItemFee',
'ItemFeeDistribution',
'ItemPackage',
'ItemQuestion',
'ItemQuestionActionableAnswer',
'ItemRule',
'ItemRuleParameter',
'ItemSalesBlackout',
'License',
'LicenseAction',
'Outlet',
'OutletBusinessHours',
'OutletPaymentMethod',
'OutletTypeItem',
'Person',
'Phone',
'PrintTemplate',
'RootItemNumber',
'SchedulePattern',
'Transaction',
'TransactionDetail',
'TransactionDetailDistribution',
'TransactionDetailFee',
'TransactionHeader'
]

BASE_FILE = r".\maintain\monitor\Focus_Migration_Source_Base.xlsx"
base_workbook = load_workbook(BASE_FILE)

LOG_FILE = r".\maintain\monitor\Focus_Migration_Change_Log.xlsx"
log_workbook = load_workbook(LOG_FILE)

TARGET_DB = acct.UAT_NJSTAGEUAT


def create_base():
    global MINITOR_TABLE_LIST
    
    table_list = ''
    for table_name in MINITOR_TABLE_LIST:
        table_list += ",'" + table_name + "'"

    df = pd.DataFrame(query_meta_data(table_list,TARGET_DB))
    df.columns = ['ref_table','ref_column','typename','precision','scale','max_length','nullable']
    df.to_excel(BASE_FILE,sheet_name = "DDL",index=False)


@logger
def validate_base(workbook,log_wb,LOG_FILE):

    change_pd = pd.DataFrame(columns = ['change_date','source_table_name','source_column_name','previous_column_type','new_column_type','previous_precision','new_precision','previous_scale','new_scale','previous_length','new_length','previous_nullable','new_nullable'])
    log_sheet = log_wb.get_sheet_by_name('Log')
    all_sheet = workbook.get_sheet_by_name('DDL')
    table_list = ''
    for cell in all_sheet['A']:
        table_list = table_list + ",'" + cell.value + "'"
 
    rs = query_meta_data(table_list,TARGET_DB)

    for row in all_sheet.rows:
        for line in rs:
            if row[0].value == line[0] and row[1].value == line[1]:
                if row[2].value != line[2] or row[3].value != line[3] or row[4].value != line[4] or row[5].value != line[5] or str(row[6].value) != str(line[6]):
                    change_pd = change_pd.append(pd.DataFrame({'change_date':[datetime.date.today()],'source_table_name':[row[0].value],'source_column_name':[row[1].value],'previous_column_type':[row[2].value],'new_column_type':[line[2]],'previous_precision':[row[3].value],'new_precision':[line[3]],'previous_scale':[row[4].value],'new_scale':[line[4]],'previous_length':[row[5].value],'new_length':[line[5]],'previous_nullable':[row[6].value],'new_nullable':[line[6]]}),ignore_index=True)
                    log_sheet.append([datetime.date.today(),row[0].value,row[1].value,row[2].value,line[2],row[3].value,line[3],row[4].value,line[4],str(row[5].value),str(line[5]),str(row[6].value).upper(),line[6]])
                break
        
    log_wb.save(LOG_FILE)
    return change_pd


if __name__ == '__main__':
    
    change_pd = validate_base(base_workbook,log_workbook,LOG_FILE)
    if not change_pd.empty:
        body = """
        Hi team,<br><br>
            Here is the NJ Migration Tables Change List for today, please take a look.<br><br><br>
        <html>
        <body>""" + change_pd.to_html(index_names=False) + '</body></html>' 
        attachments = [os.getcwd()+LOG_FILE[1:]]
        #mail('(Auto Generation) NJ Migration Tables Change List',['zongpei.liu@aspiraconnect.com;Tom.Xie@aspiraconnect.com;Aspira_DMA_AspiraFocus_Migration@aspiraconnect.com'],body,attachments)
        mail('(Auto Generation) NJ Migration Tables Change List',['zongpei.liu@aspiraconnect.com'],body,attachments)
        create_base()
    else :
        body = """
        Hi team,<br><br>
            Everything is good for NJ Migration Tables List.
        <html>
        <body> </body></html>"""
        mail('(Auto Generation) All good for NJ Migration Tables List',['zongpei.liu@aspiraconnect.com'],body)
        
    