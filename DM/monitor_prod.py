import datetime

from db_connect.sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas
import tool.TSQL_function as TSQL

import conf.acct_oracle as acct_oracle
from db_connect.oracle_db import UseOracleDB
import tool.oracle_tool as oracle_tool
import tool.tool as tool

def getMartTime():
    pass

def getAOTime():
    pass

def isDelay():
    pass

def sendMail():
    pass

US_MART_LIST = ('CO','KS')
CA_MART_LIST = ('AB')
US_AO_LIST = ('CO','KS')
CA_AO_LIST = ('AB')

US_MART_DB = acct.DEV_CA_DMA_MART
CA_MART_DB = acct.DEV_CA_DMA_MART

US_AO_DB = acct_oracle.PROD_US
CA_AO_DB = acct_oracle.PROD_US


matrix = [ [0] * 4 for i in range(5)]
matrix[0][0] = 'AB'
matrix[1][0] = 'CO'
matrix[2][0] = 'KS'
matrix[3][0] = 'MS'
matrix[4][0] = 'TX'


with UseSqlserverDB(US_MART_DB) as us_mart_cursor:
    for schema in US_MART_LIST:
        query = "SELECT MAX(ORDER_DATE_KEY) FROM " + schema + "_HF_MART.F_ORDER_ITEM_TRANSACATION WITH(NOLOCK)"
        result = TSQL.inquery_single_row(query,us_mart_cursor)

        for item in matrix:
            if item[0] == schema:
                item[2] = result

with UseSqlserverDB(CA_MART_DB) as ca_mart_cursor:
    for schema in CA_MART_LIST:
        query = "SELECT MAX(ORDER_DATE_KEY) FROM " + schema + "_HF_MART.F_ORDER_ITEM_TRANSACATION WITH(NOLOCK)"
        result = TSQL.inquery_single_row(query,us_mart_cursor)

        for item in matrix:
            if item[0] == schema:
                item[2] = result

with UseOracleDB(US_AO_DB) as us_ao_cursor:
    for schema in US_AO_LIST:
        query = "SELECT MAX(ORDER_DATE_KEY) FROM LIVE_" + schema + ". F_ORDER_ITEM_TRANSACATION WITH(NOLOCK)"
        result = oracle_tool.inquery_single_row(query,us_ao_cursor)

        for item in matrix:
            if item[0] == schema:
                item[1] = result

with UseOracleDB(CA_AO_DB) as ca_ao_cursor:
    for schema in CA_AO_LIST:
        query = "SELECT MAX(ORDER_DATE_KEY) FROM LIVE_" + schema + ". F_ORDER_ITEM_TRANSACATION WITH(NOLOCK)"
        result = oracle_tool.inquery_single_row(query,ca_ao_cursor)

        for item in matrix:
            if item[0] == schema:
                item[1] = result

for item in matrix:
    schema = item[0]
    ao_datetime_str = item[1]
    mart_datetime_str = item[2]


    ao_datetime = datetime.datetime.strptime(ao_datetime_str, '%Y-%m-%d %H:%M:%S')
    mart_datetime = datetime.datetime.strptime(mart_datetime_str, '%Y-%m-%d %H:%M:%S')
    gap = ao_datetime - mart_datetime
    print(schema + "'s gap is" + gap.days)
