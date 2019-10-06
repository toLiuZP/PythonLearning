
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

os.system("")

import conf.acct as acct
from db_connect.sqlserver_db import UseSqlserverDB, query_first_value, has_data, query
from tool.tool import file_name,logger,identify_backup_tables

TARGET_DB = acct.DEV_NJ_HF_MART
table_list = []
table_list = ['D_ADDRESS']


filename = r'.\seed\business_key.json'
with open(filename) as f:
    business_key_conf = json.load(f)

@logger
def search_empty_tables(cursor, table_list) -> list:

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
                print ("\033[32m" + table_name + "\033[0m only has -1 key row, please check.")
            else:
                not_empty_list.append(table_name)
        else:
            empty_table_counter += 1
            print ("\033[32m" + table_name + " \033[0mis empty, please check.")
        
    search_empty_result = [not_empty_list,empty_table_counter,not_validate_list]
    return search_empty_result

@logger
def check_minus_one(cursor, checking_list):

    for table_name in checking_list:
        if table_name.startswith("D_") or table_name.startswith("R_"):
            check_sql = 'SELECT TOP 1 * FROM ' + table_name + ' WITH(NOLOCK) ORDER BY 1 ASC;'
            if query_first_value(cursor,check_sql) != -1:
                print ("\033[32m" + table_name + "\033[0m does not have -1 key row, please check.")

@logger
def check_translation(cursor, checking_list):
        
    list_sql = "SELECT table_name,column_name FROM information_schema.columns WHERE table_schema = 'dbo' AND table_name in(" + checking_list + ") AND DATA_TYPE = 'varchar' AND CHARACTER_MAXIMUM_LENGTH > 14 ORDER BY table_name, ordinal_position;"
    check_list = query(cursor,list_sql)

    for item in check_list:
        table_name = item[0]
        column_name_str = str(item[1])
        
        check_sql = "SELECT TOP 1 " + column_name_str + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name_str + " LIKE '%<<translatable%'"

        if has_data(cursor,check_sql):
            print ("\n\033[32m" + table_name + "." + column_name_str + "\033[0m has un-translate string, please verify. SELECT TOP 100 " + column_name_str + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name_str + " LIKE '%<<translatable%'\n")


def check_duplicate(cursor,has_mart_source_id,has_awo_id,has_cur_rec_ind,has_current_record_ind,table_name,business_key_conf):

    if table_name.startswith("B_"):
        find_table_ind = False
        for entity in business_key_conf:
            if entity['TABLE'] == table_name:
                find_table_ind = True
            
                duplicate_check_sql = "SELECT " + entity['COLUMNS'] + " FROM " + entity['TABLE'] + entity['WHERE'] + " GROUP BY " + entity['COLUMNS'] + " HAVING COUNT(*) > 1"
                has_duplicate = has_data(cursor,duplicate_check_sql)
                if has_duplicate:
                    print ("\n\033[31m" + entity['TABLE'] + " has duplicate data on " + entity['COLUMNS'] + "\033[0m, please check by \n <<  \033[33m" + duplicate_check_sql + "\033[0m  >>\n")
        if not find_table_ind:    
            print("No conf for table: " + table_name)
    
    else:
        find_table_ind = False
        for entity in business_key_conf:
            if entity['TABLE'] == table_name:
                find_table_ind = True
        
                duplicate_check_sql = "SELECT " + entity['COLUMNS'] + " FROM " + entity['TABLE'] + entity['WHERE'] + " GROUP BY " + entity['COLUMNS'] + " HAVING COUNT(*) > 1"
                has_duplicate = has_data(cursor,duplicate_check_sql)
                if has_duplicate:
                    print ("\n\033[31m" + entity['TABLE'] + " has duplicate data on " + entity['COLUMNS'] + "\033[0m, please check by \n <<  \033[33m" + duplicate_check_sql + "\033[0m  >>\n")
        if not find_table_ind:

            if has_mart_source_id == True:
                duplicate_check_sql = "SELECT MART_SOURCE_ID FROM " + table_name + " GROUP BY MART_SOURCE_ID HAVING COUNT(*) > 1"
                has_duplicate = query_first_value(cursor,duplicate_check_sql)
                if has_duplicate:
                    print ("\n\033[31m" + table_name + " has duplicate data on MART_SOURCE_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + table_name + " WHERE MART_SOURCE_ID = " + str(has_duplicate) + "\033[0m  >>\n")

            if has_awo_id == True and has_cur_rec_ind == True:
                duplicate_check_sql = "SELECT AWO_ID FROM " + table_name + " WHERE CUR_REC_IND = 1 GROUP BY AWO_ID HAVING COUNT(*) > 1"
                has_duplicate = query_first_value(cursor,duplicate_check_sql)
                if has_duplicate:
                    print ("\n\033[31m" + table_name + " has duplicate data on MART_SOURCE_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + table_name + " WHERE MART_SOURCE_ID = " + str(has_duplicate) + "\033[0m  >>\n")

            if has_awo_id == True and has_current_record_ind == True:
                duplicate_check_sql = "SELECT AWO_ID FROM " + table_name + " WHERE CURRENT_RECORD_IND = 1 GROUP BY AWO_ID HAVING COUNT(*) > 1"
                has_duplicate = query_first_value(cursor,duplicate_check_sql)
                if has_duplicate:
                    print ("\n\033[31m" + table_name + " has duplicate data on MART_SOURCE_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + table_name + " WHERE MART_SOURCE_ID = " + str(has_duplicate) + "\033[0m  >>\n")

            elif has_awo_id == True and has_current_record_ind == False and has_cur_rec_ind == False:
                duplicate_check_sql = "SELECT AWO_ID FROM " + table_name + " GROUP BY AWO_ID HAVING COUNT(*) > 1"
                has_duplicate = query_first_value(cursor,duplicate_check_sql)
                if has_duplicate:
                    print ("\n\033[31m" + table_name + " has duplicate data on MART_SOURCE_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + table_name + " WHERE MART_SOURCE_ID = " + str(has_duplicate) + "\033[0m  >>\n")

def check_column(cursor, tb_list, business_key_conf):

    generate_raw_list = "SELECT table_name,column_name FROM information_schema.columns WHERE table_schema = 'dbo' AND table_name IN (" + tb_list + ")ORDER BY table_name, ordinal_position"
    rs_list = query(cursor,generate_raw_list)

    has_mart_source_id = False
    has_awo_id = False
    has_cur_rec_ind = False
    has_current_record_ind = False
    old_table_name = ""
    table_count = 0
    row_count = 0
    pk_column = ""

    for item in rs_list:
        table_name = item[0]
        column_name = item[1]

        
        # testing code #
        
        print("checking:  \033[32m" + table_name + "\033[0m.\033[34m" + column_name+"\033[0m")
        '''if column_name == 'D_BOND_ISSUER_KEY':
            print('test')
            pass
        '''
        

        if row_count == 0:
            pk_column = column_name
        if old_table_name != table_name:
            pk_column = column_name
            if table_count != 0:
                check_duplicate(cursor,has_mart_source_id,has_awo_id,has_cur_rec_ind,has_current_record_ind,old_table_name,business_key_conf)

            table_count += 1
            has_mart_source_id = False
            has_awo_id = False
            has_cur_rec_ind = False
            has_current_record_ind = False
            old_table_name = table_name

        # checking if column values are all NULL except the -1 one
        null_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + pk_column + " > 0 AND " + column_name + " IS NOT NULL"
        not_empty_ind = True
        not_empty_ind = has_data(cursor,null_check_sql)

        if not not_empty_ind:
            print ("\033[32m" + table_name + "." + column_name + "\033[0m is empty.")
        elif not_empty_ind:
            null_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + pk_column + " > 0 AND " + column_name + " <> ''"
            if not has_data(cursor,null_check_sql):
                print ("\033[32m" + table_name + "." + column_name + "\033[0m are all empty string.")
        elif str(column_name) == "MART_SOURCE_ID":
            has_mart_source_id = True
        elif str(column_name) == "AWO_ID":
            has_awo_id = True
        elif str(column_name) == "CUR_REC_IND":
            has_cur_rec_ind = True
        elif str(column_name) == "CURRENT_RECORD_IND":
            has_current_record_ind = True
        elif str(column_name).endswith("_KEY") and (column_name != "LABEL_KEY" and table_name != "D_TRANSLATION"):
            key_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name + " > -1" 
            if not has_data(cursor,key_check_sql):
                print ("\033[32m" + table_name + "." + column_name + "\033[0m \033[33mis all -1, please verify.\033[0m")
            
            # for KEYs, check if there is NULL value, which should NOT
            null_value_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name + " IS NULL" 
            if has_data(cursor,null_value_check_sql):
                print ("\033[32m" + table_name + "." + column_name + "\033[0m has \033[22mNULL\033[0m value, please verify.")
            
            if str(column_name).endswith("_DATE_KEY") or str(column_name).endswith("_TIME_KEY") or str(column_name).endswith("ITEM_KEY") or str(column_name).endswith("ORDER_KEY"):
                check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name + " = -1 AND " + pk_column + " > 0;"
                if has_data(cursor,check_sql):
                    print ("\033[32m" + table_name + "." + column_name + "\033[0m has \033[22m-1\033[0m value, please verify.")
        
        row_count += 1

    check_duplicate(cursor,has_mart_source_id,has_awo_id,has_cur_rec_ind,has_current_record_ind,old_table_name,business_key_conf)
    return table_count

@logger                
def check_data(cursor, table_list, business_key_conf):
    """
    1. If columns is key, validate if it's all -1.
    2. Validate if column is null.
    3. Validate if there are duplicates on awo_id/mart_source_id or business keys.
    """
    table_counter = 0

    tb_list = "'"
    for table in table_list:
        tb_list += str(table) + "','"
    tb_list = tb_list[:len(tb_list)-2]

    check_minus_one(cursor, table_list)
    #check_translation(cursor, tb_list)
    table_counter = check_column(cursor, tb_list, business_key_conf)
    
    return table_counter

if __name__ == '__main__':

    with UseSqlserverDB(TARGET_DB) as cursor:
        tables_result = search_empty_tables(cursor,table_list)

        if tables_result[2]:
            print("These following table(s) will not be been validated this time:\n")
            for table_nm in tables_result[2]:
                print(table_nm)
        if len(tables_result[0]) > 0:
            table_counter = check_data(cursor, tables_result[0],business_key_conf)
            print("\n\nThere are "+str(tables_result[1])+" empty table(s).")
            if table_counter:
                print(str(table_counter)+" non-empty table(s) verified.")
        else:
            print("\n\n\033[33mAll "+str(tables_result[1])+" table(s) are empty.\033[0m")


        
        
        


        

            