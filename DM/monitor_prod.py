

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

US_MART_LIST = ('CO_HF_MART','KS_HF_MART')
CA_MART_LIST = ('AB_HF_MART')
US_AO_LIST = ('LIVE_CO','LIVE_KS')
CA_AO_LIST = ('LIVE_AB')

US_MART_DB = acct.DEV_CA_DMA_MART
CA_MART_DB = acct.DEV_CA_DMA_MART

US_AO_DB = acct_oracle.PROD_US
CA_AO_DB = acct_oracle.PROD_US

with UseSqlserverDB(US_MART_DB) as us_mart_cursor:
    for schema in US_MART_LIST:
        query = "SELECT MAX(ORDER_DATE_KEY) FROM " + schema + ". F_ORDER_ITEM_TRANSACATION WITH(NOLOCK)"
        result = TSQL.inquery_single_row(query,us_mart_cursor)

with UseSqlserverDB(CA_MART_DB) as ca_mart_cursor:
    for schema in CA_MART_LIST:
        query = "SELECT MAX(ORDER_DATE_KEY) FROM " + schema + ". F_ORDER_ITEM_TRANSACATION WITH(NOLOCK)"
        result = TSQL.inquery_single_row(query,us_mart_cursor)

with UseOracleDB(US_AO_DB) as us_ao_cursor:
    for schema in US_AO_LIST:
        query = "SELECT MAX(ORDER_DATE_KEY) FROM " + schema + ". F_ORDER_ITEM_TRANSACATION WITH(NOLOCK)"
        result = oracle_tool.inquery_single_row(query,us_ao_cursor)

with UseOracleDB(CA_AO_DB) as ca_ao_cursor:
    for schema in CA_AO_LIST:
        query = "SELECT MAX(ORDER_DATE_KEY) FROM " + schema + ". F_ORDER_ITEM_TRANSACATION WITH(NOLOCK)"
        result = oracle_tool.inquery_single_row(query,ca_ao_cursor)
