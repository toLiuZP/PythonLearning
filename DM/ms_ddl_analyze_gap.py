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
from tool.tool import file_name,logger 

SEED_FILE = ".\seed\DDL_GAP_AB.xlsx"
nameTime = time.strftime('%Y%m%d_%H%M%S')
excelName = file_name('DDL_GAP_AB','xlsx')
workbook = load_workbook(SEED_FILE)
ddl_sheet = workbook.get_sheet_by_name('DDL')
view_sheet = workbook.get_sheet_by_name('VIEW')
index_sheet = workbook.get_sheet_by_name('INDEX')

def merge_ddl(dev, qa, sheet):

    dev = dev.fillna('null')
    qa = qa.fillna('null')

    gap = pd.merge(dev, qa, on = ['table_name','column_name'], how='outer')
    
    for index, col in gap.iterrows():
        if col[3] == col[8] and col[4] == col[9] \
            and col[5] == col[10] and col[6] == col[11] :
            '''Don't compare postion col[2] == col[7]  '''
            gap = gap.drop(index)

    gap = gap.sort_values(by = ['table_name','column_name'])

    gap = gap.reset_index(drop=True)
    for index, col in gap.iterrows():
        for i in range(0, len(col), 1):
            sheet.cell(row=index+3,column=i+1).value = col[i]
            if i in (2,3,4,5,6):
                sheet.cell(row=index+3,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="C28EEA")
            elif i in (7,8,9,10,11):   
                sheet.cell(row=index+3,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="DAC45E")

def merge_index(dev, qa, sheet):

    dev = dev.fillna('null')
    qa = qa.fillna('null')

    gap = pd.merge(dev, qa, on = ['table_nm','index_nm'], how='outer')

    for index, col in gap.iterrows():
        if col[2] == col[3]:
            gap = gap.drop(index)
                
    gap = gap.fillna('null')

    gap = gap.reset_index(drop=True)
    for index, col in gap.iterrows():
        for i in range(0, len(col), 1):
            sheet.cell(row=index+2,column=i+1).value = col[i]
            if i == 2:
                sheet.cell(row=index+2,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="C28EEA")
            elif i == 3:   
                sheet.cell(row=index+2,column=i+1).fill=sty.PatternFill(fill_type='solid',fgColor="DAC45E")

def check_ddl(workbook,ddl_sheet,db_a, db_b):

    query = "SELECT table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' AND (table_name LIKE 'D[_]%' OR table_name LIKE 'B[_]%' OR table_name LIKE 'R[_]%' OR table_name LIKE 'F[_]%' OR table_name LIKE 'RPT[_]%') ORDER BY table_name"

    new_sheet = workbook.copy_worksheet(ddl_sheet)
    new_sheet.title = "DDL"
    ddl_a = DB.query_db_pandas(query, db_a)
    ddl_b = DB.query_db_pandas(query, db_b)

    merge_ddl(ddl_a,ddl_b,new_sheet)
    
def check_index(workbook,ddl_sheet,db_a, db_b):

    query = "SELECT DISTINCT o.name as table_nm,i.name as index_nm, 'Y' as val FROM SYS.OBJECTS O JOIN SYS.index_columns IC ON IC.OBJECT_ID = O.OBJECT_ID JOIN SYS.COLUMNS C ON IC.column_id = C.column_id and C.OBJECT_ID = O.OBJECT_ID JOIN SYS.INDEXES I ON I.OBJECT_ID = O.OBJECT_ID AND I.index_id = IC.index_id JOIN information_schema.tables tab ON O.NAME = tab.TABLE_NAME AND tab.table_schema = 'dbo' WHERE o.type = 'U' AND (table_name LIKE 'D[_]%' OR table_name LIKE 'B[_]%' OR table_name LIKE 'R[_]%' OR table_name LIKE 'F[_]%' OR table_name LIKE 'RPT[_]%') ORDER BY o.name,i.name"

    new_sheet = workbook.copy_worksheet(ddl_sheet)
    new_sheet.title = "INDEX"
    index_a = DB.query_db_pandas(query, db_a)
    index_b = DB.query_db_pandas(query, db_b)

    merge_index(index_a,index_b,new_sheet)


if __name__ == '__main__':

    db_a = acct.UAT_TX_CAMPING_MART
    db_b = acct.UAT_KS_CAMPING_MART

    check_ddl(workbook,ddl_sheet,db_a,db_b)
    check_index(workbook,index_sheet,db_a,db_b)
    
workbook.remove_sheet(workbook.get_sheet_by_name('DDL'))
workbook.remove_sheet(workbook.get_sheet_by_name('VIEW'))
workbook.remove_sheet(workbook.get_sheet_by_name('INDEX'))
workbook.save(excelName)
