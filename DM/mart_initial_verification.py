
## 
# validate if there is empty table
# validate if duplciates by group by on mart_source_id/awo_id/awo_id + CUR_REC_IND / awo_id + CURRENT_RECORD_IND
# validate if any key is all -1 value or any column is all null except -1 row
# check if there is -1 row in D_ and R_
#
# TODO: change the verify for D_IDENTIFIER has duplicate data on AWO_ID, please check. SELECT * FROM D_IDENTIFIER WHERE CUR_REC_IND = 1 AND AWO_ID = 2545081
# TODO: change the verify for D_ATTRIBS has duplicate data on AWO_ID, please check. SELECT * FROM D_ATTRIBS WHERE CUR_REC_IND = 1 AND AWO_ID = 101
# TODO: add the AO_XXX_DTM veryfy, compare to XXX_DTM for time-zone shift
##
import pandas as pd
import sys
import os

os.system("")

import conf.acct as acct
from db_connect.sqlserver_db import UseSqlserverDB
import tool.tool as tool

TARGET_DB = acct.DEV_NJ_HF_MART

@tool.logger
def search_empty_tables(cursor) -> list:


    generate_empty_validation_sql = "SELECT NAME, 'SELECT TOP 2 * FROM ' + NAME + ' WITH(NOLOCK) ORDER BY 1 ASC;' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND (name NOT LIKE 'MSpeer_%' AND name NOT LIKE 'MSpub_%' AND name NOT LIKE 'syncobj_0x%' AND name NOT LIKE 'sysarticle%' AND name NOT LIKE 'sysextendedarticlesview' AND name NOT LIKE 'syspublications' AND name <> 'sysreplservers' AND name <> 'sysreplservers' AND name <> 'sysschemaarticles' AND name <> 'syssubscriptions' AND name <> 'systranschemas' AND name NOT LIKE 'O_LEGACY_%' AND name NOT LIKE 'QUEST_%' and name <> 'D_AUDIT_LOG') ORDER BY name"
    cursor.execute(generate_empty_validation_sql)
    rs_table_list = cursor.fetchall()
    not_empty_list = []

    for item in rs_table_list:
        table_name = item[0]
        sql_text = item[1]

        cursor.execute(sql_text)
        rs_is_table_empty = cursor.fetchall()

        if len(rs_is_table_empty) == 0:
            print ("\033[32m" + table_name + " \033[0mis empty, please check.")
        elif len(rs_is_table_empty) == 1 and (str(table_name).startswith("D_") or str(table_name).startswith("R_")):
             if rs_is_table_empty[0][0] == -1:
                 print ("\033[32m" + table_name + "\033[0m only has -1 key row, please check.")
        else:
            not_empty_list.append(table_name)

    return not_empty_list

@tool.logger
def check_minus_one_rows(cursor, checking_list):

    #print("\n\n\033[32m=== " + sys._getframe().f_code.co_name + " ===\033[0m\n\n")

    minus_one_sql = "SELECT NAME, 'SELECT TOP 1 * FROM ' + NAME + ' WITH(NOLOCK) ORDER BY 1 ASC;' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND (NAME LIKE 'D[_]%' OR NAME LIKE 'R[_]%') ORDER BY NAME"
    cursor.execute(minus_one_sql)
    rs_table_list = cursor.fetchall()

    for item in rs_table_list:
        table_name = item[0]
        sql_text = item[1]

        if table_name in checking_list:
            cursor.execute(sql_text)
            rs_minus_one = cursor.fetchall()
            if rs_minus_one[0][0] != -1:
                print ("\033[32m" + table_name + "\033[0m does not have -1 key row, please check.") #by using:\n\033[33m" + sql_text+"\033[0m")

def check_duplicate(cursor,has_mart_source_id,has_awo_id,has_cur_rec_ind,has_current_record_ind,old_table_name):

    if has_mart_source_id == True:
        duplicate_check_sql = "SELECT MART_SOURCE_ID FROM " + old_table_name + " GROUP BY MART_SOURCE_ID HAVING COUNT(*) > 1"
        cursor.execute(duplicate_check_sql)
        rs_has_duplicate = cursor.fetchall()
        if len(rs_has_duplicate) > 0:
            print ("\n\033[31m" + old_table_name + " has duplicate data on MART_SOURCE_ID \033[0m, please check by \n <<  \033[33mSELECT * FROM " + old_table_name + " WHERE MART_SOURCE_ID = " + str(rs_has_duplicate[0][0]) + "\033[0m  >>\n")
    if has_awo_id == True and has_cur_rec_ind == True:
        duplicate_check_sql = "SELECT AWO_ID FROM " + old_table_name + " WHERE CUR_REC_IND = 1 GROUP BY AWO_ID HAVING COUNT(*) > 1"
        cursor.execute(duplicate_check_sql)
        rs_has_duplicate = cursor.fetchall()
        if len(rs_has_duplicate) > 0:
            print ("\n\033[31m" + old_table_name + " has duplicate data on AWO_ID\033[0m, please chec by \n <<  \033[33mSELECT * FROM " + old_table_name + " WHERE CUR_REC_IND = 1 AND AWO_ID = " + str(rs_has_duplicate[0][0]) + "\033[0m  >>\n")
    if has_awo_id == True and has_current_record_ind == True:
        duplicate_check_sql = "SELECT AWO_ID FROM " + old_table_name + " WHERE CURRENT_RECORD_IND = 1 GROUP BY AWO_ID HAVING COUNT(*) > 1"
        cursor.execute(duplicate_check_sql)
        rs_has_duplicate = cursor.fetchall()
        if len(rs_has_duplicate) > 0:
            print ("\n\033[31m" + old_table_name + " has duplicate data on AWO_ID\033[0m, please check by \n <<  \033[33mSELECT * FROM " + old_table_name + " WHERE CURRENT_RECORD_IND = 1 AND AWO_ID = " + str(rs_has_duplicate[0][0]) + "\033[0m  >>\n")
    elif has_awo_id == True and has_current_record_ind == False and has_cur_rec_ind == False:
        duplicate_check_sql = "SELECT AWO_ID FROM " + old_table_name + " GROUP BY AWO_ID HAVING COUNT(*) > 1"
        cursor.execute(duplicate_check_sql)
        rs_has_duplicate = cursor.fetchall()
        if len(rs_has_duplicate) > 0:
            print ("\n\033[31m" + old_table_name + " has duplicate data on AWO_ID\033[0m, please check by \n <<  \033[33mSELECT * FROM " + old_table_name + " WHERE AWO_ID = " + str(rs_has_duplicate[0][0]) + "\033[0m  >>\n")
                
def check_data(cursor, table_list):
    """
    " 1. Validate if column is null.
    " 2. If columns is key, validate if it's all -1.
    " 3. If it's MART_SOURCE_ID, validate if it has duplicates.
    """
    
    check_minus_one_rows(cursor, table_list)

    print("\n\n\033[32m=== " + sys._getframe().f_code.co_name + " ===\033[0m\n\n")

    generate_raw_list = "SELECT table_name,column_name FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name, ordinal_position"
    cursor.execute(generate_raw_list)
    rs_list = cursor.fetchall()

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

        if table_name in table_list:

            #print(" checking on "+table_name+"."+column_name+"\n")
            if row_count == 0:
                pk_column = column_name
            if old_table_name != table_name:
                pk_column = column_name
                if table_count != 0:
                    check_duplicate(cursor,has_mart_source_id,has_awo_id,has_cur_rec_ind,has_current_record_ind,old_table_name)

                table_count = table_count + 1
                has_mart_source_id = False
                has_awo_id = False
                has_cur_rec_ind = False
                has_current_record_ind = False
                old_table_name = table_name

            # checking if column values are all NULL except the -1 one
            null_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + pk_column + " > 0 AND " + column_name + " IS NOT NULL"
            cursor.execute(null_check_sql)
            rs_has_data = cursor.fetchall()

            if len(rs_has_data) == 0:
                print ("\033[32m" + table_name + "." + column_name + "\033[0m is empty.")
            elif str(column_name) == "MART_SOURCE_ID" and str(table_name).startswith("B_") == False:
                has_mart_source_id = True
            elif str(column_name) == "AWO_ID" and str(table_name).startswith("B_") == False:
                has_awo_id = True
            elif str(column_name) == "CUR_REC_IND" and str(table_name).startswith("B_") == False:
                has_cur_rec_ind = True
            elif str(column_name) == "CURRENT_RECORD_IND" and str(table_name).startswith("B_") == False:
                has_current_record_ind = True
            elif str(column_name).endswith("_KEY") and (column_name != "LABEL_KEY" and table_name != "D_TRANSLATION"):
                key_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name + " > -1" 
                cursor.execute(key_check_sql)
                rs_is_key_minus_one = cursor.fetchall()
                if len(rs_is_key_minus_one) == 0:
                    print ("\033[32m" + table_name + "." + column_name + "\033[0m \033[33mis all -1, please verify.\033[0m")
                
                # for KEYs, check if there is NULL value, which should NOT
                null_value_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name + " IS NULL" 
                cursor.execute(null_value_check_sql)
                rs_null_check = cursor.fetchall()
                if len(rs_null_check) > 0:
                    print ("\033[32m" + table_name + "." + column_name + "\033[0m has \033[22mNULL\033[0m value, please verify.")
        row_count += 1

    check_duplicate(cursor,has_mart_source_id,has_awo_id,has_cur_rec_ind,has_current_record_ind,old_table_name)
    return table_count

if __name__ == '__main__':

    with UseSqlserverDB(TARGET_DB) as cursor:
        not_empty_list = search_empty_tables(cursor)
        table_count = check_data(cursor, not_empty_list)
        
        print("\n\n"+str(table_count)+" none-empty tables verified.")


        

            