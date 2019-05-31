import datetime

from db_connect.sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas
import tool.TSQL as TSQL

import conf.acct_oracle as acct_oracle
import conf.acct as acct
from db_connect.oracle_db import UseOracleDB
import tool.oracle_tool as oracle_tool
import tool.tool as tool

from dateutil.parser import parse
import tool.send_mail as mail

def getMartTime(mart_server, mart_list, model_type, matrix):
    with UseSqlserverDB(mart_server) as cursor:
        for schema in mart_list:
            if model_type == 'HF':
                query = "SELECT MAX(SRC_SNPSHT_DT) FROM " + schema + "_HF_MART.DBO.F_ORDER_ITEM_TRANSACTION WITH(NOLOCK)"
            elif model_type == 'Camping':
                query = "SELECT MAX(ORDER_DTM) FROM " + schema + "_CAMPING_MART.DBO.D_ORDER WITH(NOLOCK)"
            result = TSQL.inquery_single_row(query,cursor)

            for item in matrix:
                if item[0] == schema:
                    item[2] = result
                    item[4] = query
    return matrix
    

def getAOTime(ao_server, ao_list, model_type, matrix):
    with UseOracleDB(ao_server) as cursor:
        for schema in ao_list:
            if model_type == 'HF':
                query = "SELECT MAX(TRANS_DATE) FROM LIVE_" + schema + ".O_ORD_ITEM_TRANS WHERE TRANS_DATE < to_date('9990-10-10','yyyy-mm-dd')"
            elif model_type == 'Camping':
                query = "SELECT MAX(ORD_DATE) FROM LIVE_" + schema + ".O_ORDER WHERE ORD_DATE < to_date('9990-10-10','yyyy-mm-dd')"
            result = oracle_tool.inquery_single_row(query,cursor)

            for item in matrix:
                if item[0] == schema:
                    item[1] = result
                    item[3] = query
    return matrix

def isDelay():
    pass

US_HF_MART_LIST = ('CO','KS','MS')
US_CAMPING_MART_LIST = ('TX',)
CA_HF_MART_LIST = ('AB',)

US_HF_AO_LIST = ('CO','KS','MS')
US_CAMPING_HF_AO_LIST = ('TX',)
CA_HF_AO_LIST = ('AB',)

US_MART_DB = acct.PROD_CO_HF_MART
CA_MART_DB = acct.PROD_AB_HF_MART
US_AO_DB = acct_oracle.PROD_US
CA_AO_DB = acct_oracle.PROD_CDC_CA


matrix = [ [0] * 6 for i in range(4)]
matrix[0][0] = 'TX'
matrix[1][0] = 'CO'
matrix[2][0] = 'KS'
matrix[3][0] = 'MS'
#matrix[4][0] = 'AB'

warningFlg = False
mail_msg = "Following contracts have more then 8 hours gap, please check.\n\n"

#msg = "Verify start"
#mail.send_mail(msg)

getMartTime(US_MART_DB, US_HF_MART_LIST, 'HF',matrix)
getMartTime(US_MART_DB, US_CAMPING_MART_LIST, 'Camping', matrix)
#getMartTime(CA_MART_DB, CA_HF_MART_LIST, 'HF', matrix)

getAOTime(US_AO_DB, US_HF_AO_LIST, 'HF', matrix)
getAOTime(US_AO_DB, US_CAMPING_HF_AO_LIST, 'Camping', matrix)
#getAOTime(CA_AO_DB, CA_HF_AO_LIST, 'HF', matrix)

for item in matrix:
    schema = item[0]
    ao_datetime_str = item[1]
    mart_datetime_str = item[2]

    ao_datetime = parse(ao_datetime_str)
    mart_datetime = parse(mart_datetime_str)

    gap = ao_datetime - mart_datetime

    gap_hour = gap.total_seconds() / 3600

    if gap_hour > 8 :

        warningFlg = True

        mail_msg =  mail_msg + ' \r\n' + schema + " MART's latest datetime is " + str(mart_datetime_str) 
        mail_msg =  mail_msg + ' \r\n' + schema + " AO's latest datetime is " + str(ao_datetime_str) 

if warningFlg:
    #print(mail_msg)
    mail.send_mail(mail_msg)
'''else:
    mail_msg = "Everything is good"
    print(mail_msg)
    mail.send_mail(mail_msg)
    '''



    
