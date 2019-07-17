import pandas as pd
import datetime
from openpyxl import Workbook
from openpyxl import load_workbook
from openpyxl.writer.excel import ExcelWriter
import time
import openpyxl.styles as sty

import conf.acct_oracle as acct
from db_connect.oracle_db import UseOracleDB
import tool.oracle_tool as oracle_tool
from tool.tool import file_name,logger 

SEED_FILE = ".\seed\ORACLE_DDL_GAP.xlsx"
nameTime = time.strftime('%Y%m%d_%H%M%S')
excelName = file_name('ORACLE_DDL_GAP','xlsx')
workbook = load_workbook(SEED_FILE)
ddl_sheet = workbook.get_sheet_by_name('DDL')


def merge_ddl(dev, qa, sheet):

    dev = dev.fillna('null')
    qa = qa.fillna('null')
    gap = pd.merge(dev, qa, on = ['TABLE_NAME'], how='outer')
    
    for index, col in gap.iterrows():
        if str(col[1]) == 'nan' or str(col[2]) == 'nan':
            pass
        else:
            gap = gap.drop(index)

    gap = gap.sort_values(by = ['TABLE_NAME'])
    gap = gap.reset_index(drop=True)
    for index, col in gap.iterrows():
        for i in range(0, len(col), 1):
            sheet.cell(row=index+2,column=i+1).value = col[i]
            if i == 1:
                sheet.cell(row=index+2,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="C28EEA")
            elif i == 2:   
                sheet.cell(row=index+2,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="DAC45E")

def check_ddl(workbook,ddl_sheet,db_a, schema_a, db_b, schema_b):

    query_a = "SELECT TABLE_NAME, OWNER FROM ALL_TAB_COMMENTS WHERE OWNER = '" + schema_a + "' AND TABLE_TYPE = 'TABLE' AND TABLE_NAME NOT LIKE 'BIN$%' ORDER BY TABLE_NAME"
    query_b = "SELECT TABLE_NAME, OWNER FROM ALL_TAB_COMMENTS WHERE OWNER = '" + schema_b + "' AND TABLE_TYPE = 'TABLE' AND TABLE_NAME NOT LIKE 'BIN$%' ORDER BY TABLE_NAME"

    new_sheet = workbook.copy_worksheet(ddl_sheet)
    new_sheet.title = "DDL"
    ddl_a = oracle_tool.query_db_pandas(query_a, db_a)
    ddl_b = oracle_tool.query_db_pandas(query_b, db_b)

    merge_ddl(ddl_a,ddl_b,new_sheet)

if __name__ == '__main__':

    db_a = acct.QA_CDC
    schema_a = 'LIVE_CO_QA3'
    db_b = acct.UAT_CDC_US
    schema_b = 'LIVE_CO_UAT2'

    check_ddl(workbook,ddl_sheet,db_a,schema_a,db_b,schema_b)
    
workbook.remove_sheet(workbook.get_sheet_by_name('DDL'))
workbook.save(excelName)
