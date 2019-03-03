"""generate test scripts to validate data mart loading.
"""
import pandas as pd
import numpy as np

import acct
from sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas

# validate if duplciates by group by on mart_source_id
# validate if there is empty table
# validate if any key is all -1 value or any column is all null
# check if there is -1 row for D_ and R_

TEST_DB = acct.UAT_ID_CAMPING_MART

def search_empty_tables(cursor) -> list:

    generate_empty_validation_sql = "SELECT NAME, 'SELECT TOP 1 * FROM ' + NAME + ' WITH(NOLOCK);' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 ORDER BY name"
    cursor.execute(generate_empty_validation_sql)
    rs_table_list = cursor.fetchall()

    not_empty_list = []

    for item in rs_table_list:
        table_name = item[0]
        sql_text = item[1]

        cursor.execute(sql_text)
        rs_single_table_is_empty = cursor.fetchall()

        if len(rs_single_table_is_empty) == 0:
            print (table_name + " is empty, please check by using:     " + sql_text)
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
                print (table_name + " is empty, please check by using:\n" + sql_text + "\n")

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

def check_data(cursor, checking_list, acct):

    get_all_list = "SELECT NAME, 'SELECT *  FROM ' + NAME + ' WITH(NOLOCK);' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 ORDER BY name"
    cursor.execute(get_all_list)
    rs_table_list = cursor.fetchall()

    for item in rs_table_list:
        table_name = item[0]
        sql_text = item[1]

        if table_name in checking_list:

            with UseSqlserverDBPandas(acct) as conn:
                df = pd.read_sql(sql_text,conn)

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

        

if __name__ == '__main__':

    with UseSqlserverDB(TEST_DB) as cursor:

        not_empty_list = search_empty_tables(cursor)
        check_camping_duplicates(cursor)
        #check_minus_one_rows(cursor, not_empty_list)

        check_data(cursor, not_empty_list, TEST_DB)


        

            