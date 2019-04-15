###
# 1. Verify if C_CUST_HFPROFILE has data. Impact D_CUSTOMER and D_CUSTOMER_ADDRESS
###


import numpy as np
import pandas as pd
import cx_Oracle as oracle
import os

from openpyxl import Workbook

from openpyxl import load_workbook

from openpyxl.writer.excel import ExcelWriter
import time

from db_connect.sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas
import conf.acct as acct
import tool.TSQL_function as TSQL_function
import tool.tool as tool

CURRENT_DB = acct.DEV_CA_DMA_MART
#SCHEMA = 'LIVE_CO'
SEED_FILE = '.\seed\DataDictionary_Template.xlsx'

#writer = pd.ExcelWriter('DataDictionary.xlsx')

os.system("")
nameTime = time.strftime('%Y%m%d_%H%M%S')
excelName = tool.file_name('DataDictionary','xlsx')


workbook = load_workbook(SEED_FILE)
'''
sheetnames =workbook_.get_sheet_names() 

query_sheet = workbook_.get_sheet_by_name('Checking_Query')

with UseOracleDB(CURRENT_DB) as cursor:

    for sheetname in sheetnames:
        '''

with UseSqlserverDB(CURRENT_DB) as cursor:
    sheet = workbook.get_sheet_by_name('DataDictionary')
    rows = sheet.rows
    columns = sheet.columns

    for row in range(2,sheet.max_row+1):
        tableName = str(sheet.cell(row=row,column=1).value)
        columnName = str(sheet.cell(row=row,column=4).value)
        query = "SELECT TOP 1 [" + columnName + "] FROM " + tableName + " WITH(NOLOCK) WHERE [" + columnName + "] IS NOT NULL"
        result = str(TSQL_function.inquery_single_row(query,cursor))
        sheet.cell(row=row,column=12).value = result

workbook.save(excelName)  

