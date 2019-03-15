"""generate test scripts to validate data mart loading.
"""
import pandas as pd
import numpy as np

import conf.acct as acct
from db_connect.sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas

# validate if duplciates by group by on mart_source_id
# validate if there is empty table
# validate if any key is all -1 value or any column is all null
# check if there is -1 row for D_ and R_

TEST_DB = acct.UAT_CO_HF_MART

def search_empty_tables(cursor) -> list:

    generate_empty_validation_sql = "SELECT NAME, 'SELECT TOP 2 * FROM ' + NAME + ' WITH(NOLOCK) ORDER BY 1 ASC;' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND (name NOT LIKE 'MSpeer_%' AND name NOT LIKE 'MSpub_%' AND name NOT LIKE 'syncobj_0x%' AND name NOT LIKE 'sysarticle%' AND name NOT LIKE 'sysextendedarticlesview' AND name NOT LIKE 'syspublications' AND name <> 'sysreplservers' AND name <> 'sysreplservers' AND name <> 'sysschemaarticles' AND name <> 'syssubscriptions' AND name <> 'systranschemas' AND name NOT LIKE 'O_LEGACY_%' AND name NOT LIKE 'QUEST_%' and name <> 'D_AUDIT_LOG') ORDER BY name"
    cursor.execute(generate_empty_validation_sql)
    rs_table_list = cursor.fetchall()

    not_empty_list = []

    for item in rs_table_list:
        table_name = item[0]
        sql_text = item[1]

        cursor.execute(sql_text)
        rs_single_table_is_empty = cursor.fetchall()

        if len(rs_single_table_is_empty) == 0:
            print (table_name + " is empty, please check.")
        elif len(rs_single_table_is_empty) == 1 and (str(table_name).startswith("D_") or str(table_name).startswith("R_")):
             if rs_single_table_is_empty[0][0] == -1:
                 print (table_name + " only has -1 key row, please check.")
        else:
            not_empty_list.append(table_name)

    return not_empty_list

def check_camping_duplicates(cursor):

    generate_check_list = "SELECT NAME, 'SELECT MART_SOURCE_ID, COUNT(*)  FROM ' + NAME + ' WITH(NOLOCK) GROUP BY MART_SOURCE_ID HAVING COUNT(*) > 1;' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 ORDER BY name"
    cursor.execute(generate_check_list)
    rs_table_list = cursor.fetchall()

    for item in rs_table_list:
        table_name = item[0]
        sql_text = item[1]

        # check if this table has column MART_SOURCE_ID
        check_mart_source_id = "SELECT TOP 1 * FROM information_schema.columns WHERE table_name = '" + table_name + "' AND table_schema = 'dbo' AND COLUMN_NAME = 'MART_SOURCE_ID'"

        cursor.execute(check_mart_source_id)
        rs_is_mart_source_id_exist = cursor.fetchall()

        if len(rs_is_mart_source_id_exist) > 0:
            cursor.execute(sql_text)
            rs_single_table_is_empty = cursor.fetchall()

            if len(rs_single_table_is_empty) > 0:
                print ("\n" + table_name + " is empty, please check by using:\n" + sql_text + "\n")

def check_minus_one_rows(cursor, checking_list):
    minus_one_sql = "SELECT NAME, 'SELECT TOP 1 * FROM ' + NAME + ' WITH(NOLOCK) ORDER BY 1 ASC;' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 AND (NAME LIKE 'D_%' OR NAME LIKE 'R_%') ORDER BY NAME"
    cursor.execute(minus_one_sql)
    rs_table_list = cursor.fetchall()

    for item in rs_table_list:
        table_name = item[0]
        sql_text = item[1]

        if table_name in checking_list:
            cursor.execute(sql_text)
            rs_minus_one = cursor.fetchall()

            if rs_minus_one[0][0] != -1:
                print (table_name + " does not have -1 key row, please check by using:     " + sql_text)

def check_data_by_pandas(cursor, checking_list, acct):

    get_all_list = "SELECT NAME, 'SELECT *  FROM ' + NAME + ' WITH(NOLOCK);' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 ORDER BY name"
    cursor.execute(get_all_list)
    rs_table_list = cursor.fetchall()

    for item in rs_table_list:
        table_name = item[0]
        sql_text = item[1]

        if table_name in checking_list:

            print("Checking table: "+table_name)

            with UseSqlserverDBPandas(acct) as conn:
                df = pd.read_sql(sql_text,conn)

                if str(table_name).startswith("D_")  or str(table_name).startswith("R_"):
                    if df.iloc[0,0] != -1:
                        print("table " + table_name + " does not have -1 key, please verify.")

                null_check = df.count()
                for index in null_check.index:
                    if null_check[index] == 0:
                        print("table " + table_name + "." + str(index) + " is all empty, please check.")

                for column_name in df.columns:
                    if str(column_name).endswith("_KEY") == False:
                        df = df.drop(column_name, 1)
                
                df.loc['Row_sum'] = df.apply(lambda x: (x+1).sum())
                for index in df.loc['Row_sum'].index:
                    if df.loc['Row_sum'][index] == 0:
                        print("table " + table_name + "." + str(index) + " is all -1, please check.")

def check_data(cursor, table_list):

    """
    " 1. Validate if column is null first.
    " 2. If columns is key, validate if it's all -1.
    " 3. If it's MART_SOURCE_ID, validate if it has duplicates.
    """

    generate_raw_list = "SELECT table_name,column_name FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name, ordinal_position"
    cursor.execute(generate_raw_list)
    rs_list = cursor.fetchall()

    has_mart_source_id = False
    has_awo_id = False
    has_cur_rec_ind = False
    has_current_record_ind = False
    old_table_name = ""
    table_count = 0

    for item in rs_list:
        table_name = item[0]
        column_name = item[1]
           

        if table_name in table_list:

            
            if old_table_name != table_name:
                if table_count != 0:
                            if has_mart_source_id == True:
                                duplicate_check_sql = "SELECT MART_SOURCE_ID FROM " + old_table_name + " GROUP BY MART_SOURCE_ID HAVING COUNT(*) > 1"
                                cursor.execute(duplicate_check_sql)
                                rs_has_duplicate = cursor.fetchall()
                                if len(rs_has_duplicate) > 0:
                                    print ("\n !!!" + old_table_name + " has duplicate data on MART_SOURCE_ID, please check by SELECT * FROM " + old_table_name + " WHERE MART_SOURCE_ID = " + str(rs_has_duplicate[0][0]) + "\n")

                            if has_awo_id == True and has_cur_rec_ind == True:
                                duplicate_check_sql = "SELECT AWO_ID FROM " + old_table_name + " WHERE CUR_REC_IND = 1 GROUP BY AWO_ID HAVING COUNT(*) > 1"
                                cursor.execute(duplicate_check_sql)
                                rs_has_duplicate = cursor.fetchall()
                                if len(rs_has_duplicate) > 0:
                                    print ("\n !!!" + old_table_name + " has duplicate data on AWO_ID, please check. SELECT * FROM " + old_table_name + " WHERE CUR_REC_IND = 1 AND AWO_ID = " + str(rs_has_duplicate[0][0]) + "\n")
                            if has_awo_id == True and has_current_record_ind == True:
                                duplicate_check_sql = "SELECT AWO_ID FROM " + old_table_name + " WHERE CURRENT_RECORD_IND = 1 GROUP BY AWO_ID HAVING COUNT(*) > 1"
                                cursor.execute(duplicate_check_sql)
                                rs_has_duplicate = cursor.fetchall()
                                if len(rs_has_duplicate) > 0:
                                    print ("\n !!!" + old_table_name + " has duplicate data on AWO_ID, please check. SELECT * FROM " + old_table_name + " WHERE CURRENT_RECORD_IND = 1 AND AWO_ID = " + str(rs_has_duplicate[0][0]) + "\n")
                            elif has_awo_id == True and has_current_record_ind == False and has_cur_rec_ind == False:
                                duplicate_check_sql = "SELECT AWO_ID FROM " + old_table_name + " GROUP BY AWO_ID HAVING COUNT(*) > 1"
                                cursor.execute(duplicate_check_sql)
                                rs_has_duplicate = cursor.fetchall()
                                if len(rs_has_duplicate) > 0:
                                    print ("\n !!!" + old_table_name + " has duplicate data on AWO_ID, please check. SELECT * FROM " + old_table_name + " WHERE AWO_ID = " + str(rs_has_duplicate[0][0]) + "\n")

                table_count = table_count + 1
                has_mart_source_id = False
                has_awo_id = False
                has_cur_rec_ind = False
                has_current_record_ind = False

                old_table_name = table_name
            

            null_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name + " IS NOT NULL"
            cursor.execute(null_check_sql)
            rs_has_data = cursor.fetchall()

            if len(rs_has_data) == 0:
                print (table_name + "." + column_name + " is empty, please check.")
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
                    print (table_name + "." + column_name + " is all -1, please verify.")
            


  
    check_minus_one_rows(cursor, table_list)

if __name__ == '__main__':

    with UseSqlserverDB(TEST_DB) as cursor:

        not_empty_list = search_empty_tables(cursor)

        #check_data_by_pandas(cursor, not_empty_list, TEST_DB)
        check_data(cursor, not_empty_list)


        

            