###
#  monitor Focus source
#  determine if the changes impact Mart
# 
# 
# 
# 
###

import pandas as pd
import datetime
from openpyxl import Workbook
from openpyxl import load_workbook
from openpyxl.writer.excel import ExcelWriter
import time
import openpyxl.styles as sty
import os
import sys
sys.path.append(os.getcwd())

import conf.acct_focus as acct
import db_connect.db_operator as DB
from db_connect.sqlserver_db import UseSqlserverDB, query_first_value, has_data, query, execute
from tool.tool import file_name,logger,identify_backup_tables

SEED_FILE = r"D:\Work\02. SVN\Aspira\SQL\AF_Data_Mart\trunk\DataModels\NJ_HF_MART.xlsx"
seed_workbook = load_workbook(SEED_FILE)


BASE_FILE = r".\seed\Focus_Source_Base.xlsx"
excelName = r".\output\Focus_Source.xlsx"
base_workbook = load_workbook(BASE_FILE)

TARGET_DB = acct.QA_NJDMAQA
meta = pd.DataFrame(columns = ['table_type','table_name','sql'])
all_pd = pd.DataFrame(columns = ['ref_table','ref_column','typename','precision','scale','max_length','nullable','impact_list'])

def read_mapping(workbook):
    global meta
    sheet_list = ['Dimension','Bridge','Reference','Fact']
    for sheet_nm in sheet_list:
        sheet = workbook.get_sheet_by_name(sheet_nm)
        cell_nm = 'TABLE'
        for cell in sheet['C']:
            if cell.value != cell_nm:
                #print(cell.value)
                cell_nm = cell.value
                sql = sheet.cell(column=17,row = cell.row).value
                table_type = sheet.cell(column=1,row = cell.row).value
                meta = meta.append(pd.DataFrame({'table_type':[table_type],'table_name':[cell_nm],'sql':[sql]}),ignore_index=True)
                #print(sql.value)

@logger
def create_base(workbook,meta):

    all_sheet = workbook.create_sheet(title = 'ALL_DDL')
    all_sheet.append(['ref_table','ref_column','typename','precision','scale','max_length','nullable','impact_list'])
    global all_pd


    

    with UseSqlserverDB(TARGET_DB) as cursor:

        for index, row in meta.iterrows():
            tb_name = str(row['table_name'])
            sql = str(row['sql'])
            create_sql = "CREATE VIEW V_CDC_TEMP_"+ tb_name +" AS " + sql
            execute(cursor,create_sql)

            check_sql = "SELECT a.referenced_entity_name as ref_table ,a.referenced_minor_name as ref_column ,c.name as typename ,CONVERT(VARCHAR(50),b.precision) precision ,CONVERT(VARCHAR(50),b.scale) scale ,CONVERT(VARCHAR(50),b.max_length) max_length ,b.is_nullable nullable FROM sys.dm_sql_referenced_entities ( 'DBO.V_CDC_TEMP_" + tb_name + "', 'OBJECT') a inner join sys.all_columns b on a.referenced_minor_name = b.name and a.referenced_id= b.object_id inner join sys.systypes c on b.system_type_id = c.xtype where a.referenced_minor_name is not null order by 1,2"
            rs = query(cursor,check_sql)

            drop_sql = "DROP VIEW V_CDC_TEMP_"+ tb_name
            execute(cursor,drop_sql)

            sheet = workbook.create_sheet(title = tb_name[:30])
            sheet.append(['ref_table','ref_column','typename','precision','scale','max_length','nullable'])

            counter = 0
            for row in rs:

                ref_table = str(row[0])
                ref_column = str(row[1])
                typename = str(row[2])
                precision = str(row[3])
                scale = str(row[4])
                max_length = str(row[5])
                nullable = str(row[6])
                sheet.append([ref_table,ref_column,typename,precision,scale,max_length,nullable])
                impact_list = [tb_name]
                found_ind = False
                

                if ref_column == 'AddressDetailID':
                    print("test")
                    pass
                for index, row in all_pd.iterrows():

                    counter += 1
                    print(ref_table+":"+ref_column)
                    print(counter)
                    if row['ref_table'] == ref_table and row['ref_column'] == ref_column:
                        found_ind = True
                        if ref_table not in row['impact_list']:
                            row['impact_list'].append(tb_name) 
                            #row['impact_list'] = impact_list
                if not found_ind:    
                    all_pd = all_pd.append(pd.DataFrame({'ref_table':[ref_table],'ref_column':[ref_column],'typename':[typename],'precision':[precision],'scale':[scale],'max_length':[max_length],'nullable':[nullable],'impact_list':[impact_list]}),ignore_index=True)
                #if all_pd.empty:
                    #all_pd = all_pd.append(pd.DataFrame({'ref_table':[ref_table],'ref_column':[ref_column],'typename':[typename],'precision':[precision],'scale':[scale],'max_length':[max_length],'nullable':[nullable],'impact_list':[impact_list]}),ignore_index=True)




    for index, row in all_pd.iterrows():
        table_list = ''
        for table in row['impact_list']:
            table_list = table_list + "," + table

        all_sheet.append([row['ref_table'],row['ref_column'],row['typename'],row['precision'],row['scale'],row['max_length'],row['nullable'],table_list[1:]])
        
                #appendall_sheet.append([row[0],row[1],row[2],row[3],row[4],row[5],row[6]])
 

if __name__ == '__main__':

    read_mapping(seed_workbook)
    create_base(base_workbook,meta)

    base_workbook.save(excelName)
    #all_pd.to_excel(excelName,sheet_name = 'ALL_DDL', index=False, header=True)
