
## 
# validate if there is empty table
# validate if duplciates by group by on mart_source_id/awo_id/awo_id + CUR_REC_IND / awo_id + CURRENT_RECORD_IND
# validate if any key is all -1 value or any column is all null except -1 row
# check if there is -1 row in D_ and R_
#
##
import pandas as pd
import sys
import os
import json
import re
import threading 
os.system("")



import conf.acct as acct
from db_connect.sqlserver_db import UseSqlserverDB, query_first_value, has_data, query
from tool.tool import file_name,logger,identify_backup_tables

TARGET_DB = acct.PROD_KS_HF_MART
table_list = []
messager = pd.DataFrame(columns = ['msg_type','table_nm','column_nm','messager'])
#table_list = ['B_DAILY_ENTRANCE_VEHICLE_OCCUPANT']



filename = r'.\seed\business_key.json'
with open(filename) as f:
    business_key_conf = json.load(f)


class MyThread(threading.Thread):
    def __init__(self, table_nm, business_key_conf):
        super(MyThread, self).__init__() 
        self.table_nm = table_nm
        self.name = table_nm
        self.business_key_conf = business_key_conf

    def run(self):
        check_data(self.table_nm,self.business_key_conf)


def add_msg(type_nm,table_name,column_nm,msg):
    global messager
    messager = messager.append(pd.DataFrame({'msg_type':[type_nm],'table_nm':[table_name],'column_nm':[column_nm],'messager':[msg]}),ignore_index=True)


@logger 
def check_data_threading(table_list):
    tsk = []
    for table in table_list:
        t = MyThread(table,business_key_conf)
        t.start()
        tsk.append(t)
    for t in tsk:
        t.join()


@logger
def search_empty_tables(table_list) -> list:

    with UseSqlserverDB(TARGET_DB) as cursor:

        generate_empty_validation_sql = "SELECT NAME, 'SELECT TOP 2 * FROM ' + NAME + ' WITH(NOLOCK) ORDER BY 1 ASC;' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND ((name LIKE 'D[_]%' OR name LIKE 'B[_]%' OR name LIKE 'R[_]%' OR name LIKE 'F[_]%' OR name LIKE 'RPT[_]%') and name <> 'D_AUDIT_LOG') ORDER BY name"
        rs_table_list = query(cursor,generate_empty_validation_sql)
        not_empty_list = []
        empty_table_counter = 0
        not_validate_list = []

        for item in rs_table_list:
            table_name = item[0]
            sql_text = item[1]

            if identify_backup_tables(table_name.lower()):
                not_validate_list.append(table_name)
                continue

            if table_list:
                if table_name not in table_list:
                    continue
            
            rs_table_data = query(cursor,sql_text)

            if rs_table_data:
                if len(rs_table_data) == 1 and (str(table_name).startswith("D_") or str(table_name).startswith("R_")) and rs_table_data[0][0] == -1:
                    msg = "\033[32m" + table_name + "\033[0m only has -1 key row, please check."
                    add_msg('1 empty_table',table_name,'0',msg)
                else:
                    not_empty_list.append(table_name)
            else:
                empty_table_counter += 1
                msg = "\033[32m" + table_name + " \033[0mis empty, please check."
                add_msg('1 empty_table',table_name,'0',msg)
        
    search_empty_result = [not_empty_list,empty_table_counter,not_validate_list]
    return search_empty_result


def check_default_row(cursor, table_nm):

    if table_nm.startswith("D_") or table_nm.startswith("R_"):
        check_sql = 'SELECT TOP 1 * FROM ' + table_nm + ' WITH(NOLOCK) ORDER BY 1 ASC;'
        if query_first_value(cursor,check_sql) != -1:
            msg = "\033[32m" + table_nm + "\033[0m does not have -1 key row, please check."
            add_msg('2 check_default_row',table_nm,'0',msg)

        
def check_translation(cursor, table_nm):
        
    list_sql = "SELECT table_name,column_name FROM information_schema.columns WHERE table_schema = 'dbo' AND table_name ='" + table_nm + "' AND DATA_TYPE = 'varchar' AND CHARACTER_MAXIMUM_LENGTH > 14 ORDER BY table_name, ordinal_position;"
    check_list = query(cursor,list_sql)

    for item in check_list:  
        column_name_str = str(item[1])
        check_sql = "SELECT TOP 1 " + column_name_str + " FROM " + table_nm + " WITH(NOLOCK) WHERE " + column_name_str + " LIKE '%<<translatable%'"

        if has_data(cursor,check_sql):
            msg = "\n\033[32m" + table_nm + "." + column_name_str + "\033[0m has un-translate string, please verify. SELECT TOP 100 " + column_name_str + " FROM " + table_nm + " WITH(NOLOCK) WHERE " + column_name_str + " LIKE '%<<translatable%'\n"
            add_msg('3 translation',table_nm,column_name_str,msg)


def check_duplicate(cursor,has_mart_source_id,has_awo_id,has_cur_rec_ind,has_current_record_ind,table_nm,business_key_conf):

    if table_nm.startswith("B_"):
        find_table_ind = False
        for entity in business_key_conf:
            if entity['TABLE'] == table_nm:
                find_table_ind = True
                duplicate_check_sql = "SELECT " + entity['COLUMNS'] + " FROM " + entity['TABLE'] + entity['WHERE'] + " GROUP BY " + entity['COLUMNS'] + " HAVING COUNT(*) > 1"
                has_duplicate = has_data(cursor,duplicate_check_sql)
                if has_duplicate:
                    msg = "\n\033[31m" + entity['TABLE'] + " has duplicate data on " + entity['COLUMNS'] + "\033[0m, please check by \n <<  \033[33m" + duplicate_check_sql + "\033[0m  >>\n"
                    add_msg('4 duplicates',table_nm,entity['COLUMNS'],msg)
        if not find_table_ind:
            msg = "No conf for table: " + table_nm
            add_msg('4 duplicates',table_nm,'0',msg)
            
    
    else:
        find_table_ind = False
        for entity in business_key_conf:
            if entity['TABLE'] == table_nm:
                find_table_ind = True
                duplicate_check_sql = "SELECT " + entity['COLUMNS'] + " FROM " + entity['TABLE'] + entity['WHERE'] + " GROUP BY " + entity['COLUMNS'] + " HAVING COUNT(*) > 1"
                has_duplicate = has_data(cursor,duplicate_check_sql)
                if has_duplicate:
                    msg = "\n\033[31m" + entity['TABLE'] + " has duplicate data on " + entity['COLUMNS'] + "\033[0m, please check by \n <<  \033[33m" + duplicate_check_sql + "\033[0m  >>\n"
                    add_msg('4 duplicates',table_nm,entity['COLUMNS'],msg)
        if not find_table_ind:

            if has_mart_source_id == True:
                duplicate_check_sql = "SELECT MART_SOURCE_ID FROM " + table_nm + " GROUP BY MART_SOURCE_ID HAVING COUNT(*) > 1"
                has_duplicate = query_first_value(cursor,duplicate_check_sql)
                if has_duplicate:
                    msg = "\n\033[31m" + table_nm + " has duplicate data on MART_SOURCE_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + table_nm + " WHERE MART_SOURCE_ID = " + str(has_duplicate) + "\033[0m  >>\n"
                    add_msg('4 duplicates',table_nm,'MART_SOURCE_ID',msg)

            if has_awo_id == True and has_cur_rec_ind == True:
                duplicate_check_sql = "SELECT AWO_ID FROM " + table_nm + " WHERE CUR_REC_IND = 1 GROUP BY AWO_ID HAVING COUNT(*) > 1"
                has_duplicate = query_first_value(cursor,duplicate_check_sql)
                if has_duplicate:
                    msg = "\n\033[31m" + table_nm + " has duplicate data on AWO_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + table_nm + " WHERE AWO_ID = " + str(has_duplicate) + "\033[0m  >>\n"
                    add_msg('4 duplicates',table_nm,'AWO_ID',msg)

            if has_awo_id == True and has_current_record_ind == True:
                duplicate_check_sql = "SELECT AWO_ID FROM " + table_nm + " WHERE CURRENT_RECORD_IND = 1 GROUP BY AWO_ID HAVING COUNT(*) > 1"
                has_duplicate = query_first_value(cursor,duplicate_check_sql)
                if has_duplicate:
                    msg = "\n\033[31m" + table_nm + " has duplicate data on AWO_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + table_nm + " WHERE AWO_ID = " + str(has_duplicate) + "\033[0m  >>\n"
                    add_msg('4 duplicates',table_nm,'AWO_ID',msg)

            elif has_awo_id == True and has_current_record_ind == False and has_cur_rec_ind == False:
                duplicate_check_sql = "SELECT AWO_ID FROM " + table_nm + " GROUP BY AWO_ID HAVING COUNT(*) > 1"
                has_duplicate = query_first_value(cursor,duplicate_check_sql)
                if has_duplicate:
                    msg = "\n\033[31m" + table_nm + " has duplicate data on AWO_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + table_nm + " WHERE AWO_ID = " + str(has_duplicate) + "\033[0m  >>\n"
                    add_msg('4 duplicates',table_nm,'AWO_ID',msg)


def check_columns(cursor, table_nm, business_key_conf):

    generate_raw_list = "SELECT table_name,column_name,ordinal_position, data_type FROM information_schema.columns WHERE table_schema = 'dbo' AND table_name = '" + table_nm + "' ORDER BY ordinal_position"
    rs_list = query(cursor,generate_raw_list)

    has_mart_source_id = False
    has_awo_id = False
    has_cur_rec_ind = False
    has_current_record_ind = False

    for item in rs_list:
        column_name = str(item[1])
        position = item[2]
        #data_type = str(item[3])
        
        # Log #
        '''
        print("checking:  \033[32m" + table_nm + "\033[0m.\033[34m" + column_name+"\033[0m")
        if column_name == 'CUSTOMER_NB':
            print('test')
            pass
        '''

        if position == 1:
            pk_column = column_name

        # checking if column values are all NULL except the -1 one
        null_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_nm + " WITH(NOLOCK) WHERE " + pk_column + " > 0 AND " + column_name + " IS NOT NULL"

        if not has_data(cursor,null_check_sql):
            msg = "\033[32m" + table_nm + "." + column_name + "\033[0m is empty."
            add_msg('5 column_check',table_nm,column_name,msg)
            
        elif column_name == "MART_SOURCE_ID":
            has_mart_source_id = True
        elif column_name == "AWO_ID":
            has_awo_id = True
        elif column_name == "CUR_REC_IND":
            has_cur_rec_ind = True
        elif column_name == "CURRENT_RECORD_IND":
            has_current_record_ind = True
        elif column_name.endswith("_KEY") and column_name != "LABEL_KEY" and table_nm != "D_TRANSLATION":
            key_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_nm + " WITH(NOLOCK) WHERE " + column_name + " > -1" 
            if not has_data(cursor,key_check_sql):
                msg = "\033[32m" + table_nm + "." + column_name + "\033[0m \033[33mis all -1, please verify.\033[0m"
                add_msg('5 column_check',table_nm,column_name,msg)
            
            # for KEYs, check if there is NULL value, which should NOT
            null_value_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_nm + " WITH(NOLOCK) WHERE " + column_name + " IS NULL" 
            if has_data(cursor,null_value_check_sql):
                msg = "\033[32m" + table_nm + "." + column_name + "\033[0m has \033[22mNULL\033[0m value, please verify."
                add_msg('5 column_check',table_nm,column_name,msg)
            
            if column_name.endswith("_DATE_KEY") or column_name.endswith("_TIME_KEY") or column_name.endswith("ITEM_KEY") or column_name.endswith("ORDER_KEY"):
                check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_nm + " WITH(NOLOCK) WHERE " + column_name + " = -1 AND " + pk_column + " > 0;"
                if has_data(cursor,check_sql):
                    msg = "\033[32m" + table_nm + "." + column_name + "\033[0m has \033[22m-1\033[0m value, please verify."
                    add_msg('5 column_check',table_nm,column_name,msg)

    check_duplicate(cursor,has_mart_source_id,has_awo_id,has_cur_rec_ind,has_current_record_ind,table_nm,business_key_conf)

               
def check_data(table_nm, business_key_conf):
    """
    1. If columns is key, validate if it's all -1.
    2. Validate if column is null.
    3. Validate if there are duplicates on awo_id/mart_source_id or business keys.
    """
    with UseSqlserverDB(TARGET_DB) as cursor:

        check_default_row(cursor, table_nm)
        check_translation(cursor, table_nm)
        check_columns(cursor, table_nm, business_key_conf)
    

if __name__ == '__main__':
    
        tables_result = search_empty_tables(table_list)
        
        if len(tables_result[0]) > 0:
            check_data_threading(tables_result[0])

            print("\n\nThere are "+str(tables_result[1])+" empty table(s).")
            if len(messager['table_nm'].unique()):
                messager = messager.sort_values(by=['msg_type','table_nm','column_nm'])
                for index, row in messager.iterrows():
                    print (row["messager"])
                print(str(len(messager['table_nm'].unique()))+" non-empty table(s) verified.")
        else:
            print("\n\n\033[33mAll "+str(tables_result[1])+" table(s) are empty.\033[0m")

        if tables_result[2]:
            print("These following table(s) will not be been validated this time:\n")
            for table_nm in tables_result[2]:
                print(table_nm)
    
    



        
        
        


        

            