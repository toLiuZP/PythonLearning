## 
# copy the header for DB
# If new tables created, drop the new tables.
# else
#   If new indexes created, drop the new indexes
#   If new columns added, drop these new columns
#   If drop or alter exist columns, need manually modify.
##

import os
import sys
sys.path.append(os.getcwd())
from tool.tool import file_name 

new_table_list = []
rollback_sql = ''
rest_sql = ''

def gen_drop_table(drop_table_nm)->str:
    sql = '''
IF OBJECT_ID('[dbo].[table_nm]') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[table_nm]
    IF OBJECT_ID('[dbo].[table_nm]') IS NOT NULL
        PRINT '[INFO] FAILED DROPPING TABLE DBO.table_nm ';
    ELSE
        PRINT '[INFO] DROPPED TABLE DBO.table_nm ';
END

'''.replace('table_nm',drop_table_nm)
    return sql

def gen_drop_index(drop_table_nm:str, drop_index_nm:str)->str:
    sql = '''
IF EXISTS(SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('DBO.table_nm') AND name='index_nm')
BEGIN
	DROP INDEX DBO.table_nm.index_nm
	PRINT '[INFO] DROPED INDEX [DBO].[table_nm].[index_nm]'
END

'''.replace('table_nm',drop_table_nm).replace('index_nm',drop_index_nm)
    return sql

def gen_drop_column(drop_table_nm:str, drop_column_nm:str)->str:
    sql = '''
IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.table_nm') AND name='column_nm')
BEGIN
	ALTER TABLE DBO.table_nm DROP COLUMN column_nm
	PRINT '[INFO] DROPED COLUMN [DBO].[table_nm].[column_nm]'
END

'''.replace('table_nm',drop_table_nm).replace('column_nm',drop_column_nm)
    return sql


filename = '.\seed\gen.sql'
with open(filename) as file_object:
    rollback_sql += file_object.readline()
    rollback_sql += file_object.readline()
    rollback_sql += file_object.readline()
    lines = file_object.readlines()


for line in lines:
    line = line.replace('\t','').replace('\n','').replace('[','').replace(']','').upper() 
    # genreate drop table statement
    if line.startswith("CREATE TABLE"):
        start_position = line.find('.')
        table_nm = line[start_position+1:].replace(' ','')
        end_position = table_nm.find('(')
        table_nm = table_nm[:end_position]
        new_table_list.append(table_nm)
        rollback_sql += gen_drop_table(table_nm)
        #print(table_nm)
    # genreate drop index statement
    elif line.startswith("IF NOT EXISTS (SELECT * FROM SYS.INDEXES"):
        table_start_position = line.find("OBJECT_ID('")
        table_end_position = line.find("')")
        table_nm = line[table_start_position+15:table_end_position]

        index_start_position = line[table_end_position:].lstrip().find("NAME='")
        index_nm = line[table_end_position+index_start_position+6:]
        index_end_position = index_nm.find("')")
        index_nm = index_nm[:index_end_position]

        if table_nm not in new_table_list:
            rollback_sql += gen_drop_index(table_nm,index_nm)
            #print(table_nm+"."+index_nm)
    elif line.startswith("IF NOT EXISTS (SELECT TOP 1 1 FROM SYS.INDEXES"):
        table_start_position = line.find("OBJECT_ID('")
        table_end_position = line.find("','U')")
        table_nm = line[table_start_position+15:table_end_position]

        index_start_position = line[table_end_position:].lstrip().find("NAME='")
        index_nm = line[table_end_position+22:]
        index_end_position = index_nm.find("')")
        index_nm = index_nm[:index_end_position]

        if table_nm not in new_table_list:
            rollback_sql += gen_drop_index(table_nm,index_nm)
            #print(table_nm+"."+index_nm)
    # genreate drop column statement
    elif line.startswith("ALTER TABLE "):
        orignal_sql = line
        line = line.replace('ALTER TABLE','').lstrip().replace('DBO.','')

        table_end_position = line.find(" ")
        table_nm = line[:table_end_position]

        line = line[table_end_position:].lstrip()

        if line.startswith("ADD"):
            line = line.replace('ADD','').lstrip()
            column_end_position = line.find(" ")
            column_nm = line[:column_end_position]

            if table_nm not in new_table_list:
                rollback_sql += gen_drop_column(table_nm,column_nm)
                #print(table_nm+"."+column_nm)
        if line.startswith("DROP COLUMN") or line.startswith("ALTER COLUMN"):
            print("Need manually handle: "+ orignal_sql)
    else:
        rest_sql += line + "\n"

rollbackfilename = file_name("rollback",".sql")
with open(rollbackfilename, 'w') as file_object:
    file_object.write(rollback_sql)

restfilename = file_name("restforaduit",".sql")
with open(restfilename, 'w') as file_object:
    file_object.write(rest_sql)
