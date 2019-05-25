import sys

from db_connect.sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas

def inquery_single_row(query, cursor):

    print(query)    
    
    cursor.execute(query)
    result = cursor.fetchall()
    if len(result) > 0:
        return str(result[0][0])
    else :
        return ''

def search_empty_tables(cursor) -> list:

    print("\033[32m=== " + sys._getframe().f_code.co_name + " ===\033[0m\n\n")

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

def check_minus_one_rows(cursor, checking_list):

    print("\n\n\033[32m=== " + sys._getframe().f_code.co_name + " ===\033[0m\n\n")

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
