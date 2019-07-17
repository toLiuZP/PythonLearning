## 
# copy the header for DB
# If new tables created, drop the new tables.
# else
#   If new indexes created, drop the new indexes
#   If new columns added, drop these new columns
#   If drop or alter exist columns, need manually modify.
# TODO: F_ORDER_ITEM_TRANSACTION.VEHICLE_ADDITIONAL_SURCHARGE_FEE_AMT
##

import os
import sys
sys.path.append(os.getcwd())
from tool.tool import file_name 

file_group = ''
new_table_list = []
rollback_sql = ''
rename_sql = ''
drop_index_sql = ''
add_index_sql = ''
add_backup_table_sql = ''
column_sql = ''
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

def gen_add_index(drop_table_nm:str, drop_index_nm:str, file_group:str)->str:
    sql = '''
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.table_nm') AND name='index_nm')
BEGIN
	CREATE NONCLUSTERED INDEX [index_nm] ON [dbo].[table_nm](XXXXXXXXXXX)
	WITH (PAD_INDEX= OFF,STATISTICS_NORECOMPUTE =OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING= OFF, MAXDOP=0, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS= ON)
	ON INDEX_FILE_GROUP
	PRINT '<<< CREATED INDEX dbo.table_nm.index_nm >>>'
END

'''.replace('INDEX_FILE_GROUP',file_group+'_IDX').replace('table_nm',drop_table_nm).replace('index_nm',index_nm)
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

def gen_add_column(drop_table_nm:str, drop_column_nm:str)->str:
    sql = '''
IF NOT EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.table_nm') AND name='column_nm')
BEGIN
	ALTER TABLE DBO.table_nm ADD column_nm XXXXXXXXXXX
	PRINT '[INFO] ADDED COLUMN [DBO].[table_nm].[column_nm]'
END

'''.replace('table_nm',drop_table_nm).replace('column_nm',drop_column_nm)
    return sql

def gen_rename_table(original_table_nm:str, new_table_nm:str)->str:
    sql = '''
IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'new_table_nm')
BEGIN
	EXEC sp_rename 'dbo.new_table_nm', 'original_table_nm'; 
	PRINT 'Renamed [DBO].[new_table_nm] to [original_table_nm]'
END

'''.replace('original_table_nm',original_table_nm).replace('new_table_nm',new_table_nm)
    return sql

def gen_rename_column(table_nm:str, new_column_nm:str, original_column_nm:str)->str:
    sql = '''
IF EXISTS(SELECT * from dbo.syscolumns WHERE id=object_id('dbo.table_nm') AND name='new_column_nm')
BEGIN
	EXEC SP_RENAME 'table_nm.new_column_nm', 'original_column_nm', 'COLUMN'
	PRINT '[INFO] UPDATED [DBO].[table_nm].[new_column_nm] to [original_column_nm]'
END

'''.replace('table_nm',table_nm).replace('new_column_nm',new_column_nm).replace('original_column_nm',original_column_nm)
    return sql


def gen_add_back_table(original_table_nm:str, new_table_nm:str)->str:
    sql = '''
IF EXISTS(SELECT * FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND NAME = 'new_table_nm')
BEGIN
	DROP TABLE original_table_nm
	EXEC sp_rename 'dbo.new_table_nm', 'original_table_nm'; 
	PRINT 'Renamed [DBO].[new_table_nm] to [original_table_nm]'
END

'''.replace('original_table_nm',original_table_nm).replace('new_table_nm',new_table_nm)
    return sql


filename = r'.\seed\release_scripts.sql'
with open(filename) as file_object:
    first_line = file_object.readline()
    file_group = first_line[4:]
    rollback_sql += first_line
    rollback_sql += file_object.readline()
    rollback_sql += file_object.readline()
    lines = file_object.readlines()


for line in lines:
    line = line.replace('\t','').replace('\n','').replace('[','').replace(']','').upper().lstrip()
    # generate drop table statement
    if line.startswith("CREATE TABLE"):
        start_position = line.find('.')
        table_nm = line[start_position+1:].replace(' ','')
        end_position = table_nm.find('(')
        table_nm = table_nm[:end_position]
        new_table_list.append(table_nm)
        rollback_sql += gen_drop_table(table_nm)
    # generate rename table statement
    elif line.startswith("EXEC SP_RENAME") and line.endswith("'COLUMN'") == False:
        original_table_start_position = line.find('.')
        original_table_end_position = line.find("'",original_table_start_position)
        original_table_name = line[original_table_start_position+1:original_table_end_position]

        new_table_start_position = line.find("'",original_table_end_position+1)
        new_table_end_position = line.find("'",new_table_start_position+1)
        new_table_name = line[new_table_start_position+1:new_table_end_position]

        rename_sql += gen_rename_table(original_table_name,new_table_name)
    # generate rename column statement
    elif line.startswith("EXEC SP_RENAME"):
        table_end_position = line.find('.')
        table_start_position = line.find("'")
        table_name = line[table_start_position+1:table_end_position]

        original_column_start_position = line.find('.')
        original_column_end_position = line.find("'",original_column_start_position)
        original_column_name = line[original_column_start_position+1:original_column_end_position]

        new_column_start_position = line.find("'",original_column_end_position+1)
        new_column_end_position = line.find("'",new_column_start_position+1)
        new_column_name = line[new_column_start_position+1:new_column_end_position]

        rename_sql += gen_rename_column(table_name, new_column_name,original_column_name)

    # generate drop index statement
    elif line.startswith("CREATE NONCLUSTERED INDEX"):
        index_start_position = line.find("CREATE NONCLUSTERED INDEX ")
        index_end_position = line.find(" ON")
        index_nm = line[index_start_position+26:index_end_position]

        table_string = line[index_end_position:].lstrip()
        table_start_position = table_string.find("DBO.")
        table_end_position = table_string.find("(")
        table_nm = table_string[table_start_position+4:table_end_position]

        if table_nm not in new_table_list:
            drop_index_sql += gen_drop_index(table_nm,index_nm)

    # generate add index statement
    elif line.startswith("DROP INDEX"):
        index_start_position = line.find("DROP INDEX ")
        index_end_position = line.find(" ON")
        index_nm = line[index_start_position+11:index_end_position]

        table_string = line[index_end_position:].lstrip()
        table_start_position = table_string.find("DBO.")
        table_nm = table_string[table_start_position+4:]

        if table_nm not in new_table_list:
            add_index_sql += gen_add_index(table_nm,index_nm,file_group)

    # generate rollback for columns change
    elif line.startswith("ALTER TABLE "):
        orignal_sql = line
        line = line.replace('ALTER TABLE ','').lstrip().replace('DBO.','')

        table_end_position = line.find(" ")
        table_nm = line[:table_end_position]

        line = line[table_end_position:].lstrip()
        
        # generate drop column statement for new added columns
        if line.startswith("ADD"):
            line = line.replace('ADD ','').lstrip()
            column_end_position = line.find(" ")
            column_nm = line[:column_end_position]

            if table_nm not in new_table_list:
                column_sql += gen_drop_column(table_nm,column_nm)
        
        # generate add column statement for dropped columns
        '''
        if line.startswith("DROP COLUMN") :
            line = line.replace('DROP COLUMN','').lstrip()
            column_end_position = line.find(" ")
            column_nm = line[:column_end_position]

            if table_nm not in new_table_list:
                column_sql += gen_add_column(table_nm,column_nm)
                print("Need manually handle: \033[32m"+ orignal_sql+"\033[0m for column type")

        if line.startswith("DROP COLUMN") or line.startswith("ALTER COLUMN"):
            print("Need manually handle: \033[32m"+ orignal_sql+"\033[0m")
        '''
    # generate add backup table statement
    elif line.startswith("SELECT * INTO"):
        new_table_start_position = line.find("SELECT * INTO ")
        new_table_end_postion = line.find(" FROM")
        new_table_nm = line[new_table_start_position+14:new_table_end_postion]

        original_table_start_position = line.find("FROM")
        if line.endswith("WITH(NOLOCK)"):
            new_table_end_postion = line.find(" WITH(NOLOCK)")
            original_table_nm = line.rstrip()[original_table_start_position+5:new_table_end_postion]
        else:
            original_table_nm = line.rstrip()[original_table_start_position+5:]

        add_backup_table_sql += gen_add_back_table(original_table_nm,new_table_nm)
   
    else:
        rest_sql += line + "\n"

rollback_sql += drop_index_sql
rollback_sql += column_sql
rollback_sql += add_index_sql
rollback_sql += rename_sql
rollback_sql += add_backup_table_sql


rollbackfilename = file_name("rollback","sql")
with open(rollbackfilename, 'w') as file_object:
    file_object.write(rollback_sql)

restfilename = file_name("restforaduit","sql")
with open(restfilename, 'w') as file_object:
    file_object.write(rest_sql)
