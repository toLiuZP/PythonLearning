###
# TODO: Need to update to keep the format of spreadsheet.
###

import pandas as pd
import datetime
from openpyxl import Workbook
from openpyxl import load_workbook
from openpyxl.writer.excel import ExcelWriter
import time
import openpyxl.styles as sty

import conf.acct as acct
import db_connect.db_operator as DB
from tool.tool import file_name 

SEED_FILE = ".\seed\DDL_GAP.xlsx"
nameTime = time.strftime('%Y%m%d_%H%M%S')
excelName = file_name('DDL_GAP','xlsx')
workbook = load_workbook(SEED_FILE)
ddl_sheet = workbook.get_sheet_by_name('DDL')

check_list = ['CO_HF_MART','KS_HF_MART']

def merge(dev, qa, uat, sheet, prod='none'):

    dev = dev.fillna('null')
    qa = qa.fillna('null')
    uat = uat.fillna('null')

    gap = pd.merge(dev, qa, on = ['table_name','column_name'], how='outer')
    gap = pd.merge(gap, uat, on = ['table_name','column_name'], how='outer')

    if isinstance(prod, str):
        for index, col in gap.iterrows():
            if col[3] == col[8] == col[13] and col[4] == col[9] == col[14] \
                and col[5] == col[10] == col[15] and col[6] == col[11] == col[16]:
                '''Don't compare postion col[2] == col[7] == col[12] and '''
                gap = gap.drop(index)
                
    else:
        for index, col in gap.iterrows():
            prod = prod.fillna('null')
            gap = pd.merge(gap, prod, on = ['table_name','column_name'], how='outer')
            if  col[3] == col[8] == col[13]  == col[18] and col[4] == col[9] == col[14]  == col[19] \
                and col[5] == col[10] == col[15]  == col[20] and col[6] == col[11] == col[16]  == col[21]:
                '''Don't compare postion col[2] == col[7] == col[12] == col[17] and'''
                gap = gap.drop(index)
    

    gap = gap.reset_index(drop=True)

    

    for index, col in gap.iterrows():
        for i in range(0, len(col), 1):
            sheet.cell(row=index+3,column=i+1).value = col[i]
            if i in (2,3,4,5,6):
                sheet.cell(row=index+3,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="C28EEA")
            elif i in (7,8,9,10,11):   
                sheet.cell(row=index+3,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="DAC45E")
            elif i in (12,13,14,15,16):
                sheet.cell(row=index+3,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="68AE59")
            elif i in (17,18,19,20,21):
                sheet.cell(row=index+3,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="5B7190")

if __name__ == '__main__':

    # US contracts:

    for contract in check_list:

        query = "SELECT table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM " + contract + ".information_schema.columns WHERE table_schema = 'dbo' AND table_name NOT LIKE 'MSpeer_%' AND table_name NOT LIKE 'MSpub_%' AND table_name NOT LIKE 'syncobj_0x%' AND table_name NOT LIKE 'sysarticle%' AND table_name NOT LIKE 'sysextendedarticlesview' AND table_name NOT LIKE 'syspublications' AND table_name <> 'sysreplservers' AND table_name <> 'sysreplservers' AND table_name <> 'sysschemaarticles' AND table_name <> 'syssubscriptions' AND table_name <> 'systranschemas' ORDER BY table_name"

        new_ddl_sheet = workbook.copy_worksheet(ddl_sheet)
        new_ddl_sheet.title = contract + "_DDL"
        dev = DB.query_db_pandas(query, acct.DEV_CO_HF_MART)
        qa = DB.query_db_pandas(query, acct.QA_CO_HF_MART)
        uat = DB.query_db_pandas(query, acct.UAT_CO_HF_MART)
        #prod = DB.query_db_pandas(query, acct.PROD_CO_HF_MART)

        merge(dev,qa,uat,new_ddl_sheet)

    
workbook.remove_sheet(workbook.get_sheet_by_name('DDL'))
workbook.remove_sheet(workbook.get_sheet_by_name('VIEW'))
workbook.save(excelName)
