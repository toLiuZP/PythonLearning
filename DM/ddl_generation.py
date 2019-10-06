###
# generate DDL based on mapping (NJ version)
###

import os

from openpyxl import Workbook
from openpyxl import load_workbook
import time

from tool.tool import save_file

os.system("")

SEED_FILE = r".\seed\Mapping.xlsx"
nameTime = time.strftime('%m/%d/%Y')
workbook = load_workbook(SEED_FILE)
sheetnames =workbook.get_sheet_names() 

check_list = ['D_HUNT_APPLICATION','B_HUNT_APPLICATION_CHOICE','B_HUNT_APPLICATION_CUSTOMER','B_HUNT_TYPE_LICENSE_YEAR_HUNT','D_DRAW','D_HUNT_TYPE_LICENSE_YEAR','F_HUNT_TYPE_LICENSE_YEAR_DRAW_STATISTICS','B_HUNT_TYPE_LICENSE_YEAR_HUNT_GENERATION']


HEADER = '''
/*
 * NOTES: Creates [R_TABLE_NM] for AspiraFocus datamart 
 *
 * DATE      	JIRA    	USER       		DESCRIPTION
 * ----------	--------	-----------		---------------------------------------
 * [R_TODAY]	DMA-4999	Zongpei Liu		Initialization.
*/

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

IF OBJECT_ID('DBO.[R_TABLE_NM]') IS NULL
BEGIN
	CREATE TABLE DBO.[R_TABLE_NM](
'''

PK_COLUMN = '		[R_COLUMN_NM]						[R_COLUMN_TYPE]		IDENTITY(1,1),\n'
N_COLUMN = '		[R_COLUMN_NM]						[R_COLUMN_TYPE]		NULL,\n'
COMMENT = "	exec sys.sp_addextendedproperty 'MS_Description', '[R_COMMENT]', 'schema', 'dbo', 'table', '[R_TABLE_NM]', 'column', '[R_COLUMN_NM]'\n"
INDEX = '''
IF NOT EXISTS( SELECT TOP 1 1 FROM sys.indexes i WHERE i.object_id = object_id('[dbo].[[R_TABLE_NM]]','U') AND i.name = '[R_TABLE_NM]_[R_COLUMN_NM]')
BEGIN
    CREATE NONCLUSTERED INDEX [[R_TABLE_NM]_[R_COLUMN_NM]] ON [dbo].[[R_TABLE_NM]]([[R_COLUMN_NM]]) ON {INDEXFG}
    PRINT '[INFO] CREATED NONCLUSTERED INDEX [dbo].[[R_TABLE_NM]].[[R_TABLE_NM]_[R_COLUMN_NM]]'
END\n
'''

for table_nm in check_list:

    ddl = ''
    comment_text = ''
    row_count = 0
    pk_column = ''
    has_mart_source_id = False
    index = ''
    ddl += HEADER.replace('[R_TABLE_NM]',table_nm).replace('[R_TODAY]',nameTime) 

    for sheetname in sheetnames:
        table_found = False
        if sheetname != 'ChangeLog':
            sheet = workbook.get_sheet_by_name(sheetname)
            for row in range(1,sheet.max_row+1):
                if sheet.cell(row=row,column=3).value == table_nm:
                    table_found = True
                    column_nm = str(sheet.cell(row=row,column=4).value)
                    column_type = str(sheet.cell(row=row,column=6).value)
                    column_comment = str(sheet.cell(row=row,column=19).value)
                    row_count +=1
                    if row_count == 2:
                        ddl += PK_COLUMN.replace('[R_COLUMN_NM]',column_nm).replace('[R_COLUMN_TYPE]',column_type)
                        comment_text += COMMENT.replace('[R_COLUMN_NM]',column_nm).replace('[R_TABLE_NM]',table_nm).replace('[R_COMMENT]',column_comment)
                        pk_column = column_nm
                    if row_count > 2:
                        ddl += N_COLUMN.replace('[R_COLUMN_NM]',column_nm).replace('[R_COLUMN_TYPE]',column_type)
                        comment_text += COMMENT.replace('[R_COLUMN_NM]',column_nm).replace('[R_TABLE_NM]',table_nm).replace('[R_COMMENT]',column_comment)
                        if column_nm == 'MART_SOURCE_ID':
                            has_mart_source_id = True
                        if column_nm.endswith('_KEY'):
                            index += INDEX.replace('[R_TABLE_NM]',table_nm).replace('[R_COLUMN_NM]',column_nm)
            if table_found:
                ddl += '''		CONSTRAINT PK_[R_TABLE_NM] PRIMARY KEY CLUSTERED (R_PK_COLUMN)
    )ON [{TABLEFG}]\n\n'''.replace('[R_TABLE_NM]',table_nm).replace('R_PK_COLUMN',pk_column)
                ddl += comment_text
                ddl += '''\n\n	PRINT '[INFO] CREATED TABLE [DBO].[[R_TABLE_NM]]'
END\n\n'''.replace('[R_TABLE_NM]',table_nm)
                if has_mart_source_id:
                    ddl += INDEX.replace('[R_TABLE_NM]',table_nm).replace('[R_COLUMN_NM]','MART_SOURCE_ID')
                ddl += index

    save_file('.\output\ddl\\'+table_nm+'.sql',ddl)





   
