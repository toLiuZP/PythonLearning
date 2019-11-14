from openpyxl import Workbook
from openpyxl import load_workbook
import pandas as pd
import os
import sys
sys.path.append(os.getcwd())
from tool.tool import file_name 


SEED_FILE = r".\seed\Column_gen.xlsx"
meta = pd.read_excel(SEED_FILE)
f = open(file_name("Gen_Script",".sql"), "w")  

sql_txt = '''
IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.D_CUSTOMER_PROFILE') AND name='column_to_replace')
BEGIN
	ALTER TABLE D_CUSTOMER_PROFILE ADD column_to_replace varchar(256) NULL
	exec sys.sp_addextendedproperty 'MS_Description', 'xxxxxxxxxxxxxxxxxx', 'schema', 'dbo', 'table', 'D_CUSTOMER_PROFILE', 'column', 'column_to_replace'
	PRINT '[INFO] ADD COLUMN [DBO].[D_CUSTOMER_PROFILE].[column_to_replace]'
END
'''

for index, col in meta.iterrows():
	print(sql_txt.replace('column_to_replace',col[0]).replace('xxxxxxxxxxxxxxxxxx',col[1]))
	f.write(sql_txt.replace('column_to_replace',col[0]).replace('xxxxxxxxxxxxxxxxxx',col[1]))
	
f.close()



'''
column_list = (
'QUESTION_ANIMAL_TYPE_VAL'
,'QUESTION_WEIGHT_VAL'
)

f = open(file_name("Gen_Script",".sql"), "w")  

for item in column_list:
	print(drop_sql_txt.replace('column_to_replace',item))
	f.write(drop_sql_txt.replace('column_to_replace',item))
f.close()
'''