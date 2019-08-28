
import sys

from db_connect.sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas, query


def inquery_single_row(query, cursor):
    
    #print(query)    
    cursor.execute(query)
    result = cursor.fetchall()
    if len(result) > 0:
        return str(result[0][0])
    else :
        return ''
'''
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

def search_db(cursor) -> list:

    search_db_sql = "SELECT NAME FROM Master..SysDatabases WHERE NAME LIKE '%MART%' AND NAME NOT IN ('MS_HF_MART2') AND NAME NOT LIKE '%CMPG_MART' ORDER BY Name"
    cursor.execute(search_db_sql)
    rs_table_list = cursor.fetchall()

    return rs_table_list

def search_column(cursor, db_name, column_name, column_type = 'None', column_len = 'None',table_name = 'None') -> list:

    search_db_sql = "SELECT NULL AS db_name, d.name AS table_name, a.colorder AS column_order, a.name AS column_name, CASE WHEN COLUMNPROPERTY( a.id,a.name,'IsIdentity')=1 THEN '1' ELSE '0' END AS is_identity, CASE WHEN EXISTS (SELECT 1 FROM {SOURCE_SCHEMA}.dbo.sysobjects WHERE xtype='PK' AND name IN (SELECT name FROM {SOURCE_SCHEMA}.dbo.sysindexes WHERE indid IN (SELECT indid FROM {SOURCE_SCHEMA}.dbo.sysindexkeys WHERE id = a.id AND colid=a.colid ) ) ) THEN '1' ELSE '0' END AS is_pk, b.name AS column_type, a.length AS column_len, isnull(COLUMNPROPERTY(a.id,a.name,'Scale'),0) AS scale_len, CASE WHEN a.isnullable=1 THEN '1' ELSE '0' END AS nullable, g.[value] AS column_desc FROM {SOURCE_SCHEMA}.dbo.syscolumns a LEFT JOIN {SOURCE_SCHEMA}.dbo.systypes b ON a.xusertype=b.xusertype INNER JOIN {SOURCE_SCHEMA}.dbo.sysobjects d ON a.id =d.id AND d.xtype='U' AND d.name<>'dtproperties' LEFT JOIN dbo.syscomments e ON a.cdefault=e.id LEFT JOIN sys.extended_properties g ON a.id =g.major_id AND a.colid=g.minor_id LEFT JOIN sys.extended_properties f ON d.id =f.major_id AND f.minor_id=0 LEFT JOIN {SOURCE_SCHEMA}.INFORMATION_SCHEMA.TABLES table_schema ON d.name = table_schema.table_name WHERE table_schema.table_schema = 'dbo' ".replace('{SOURCE_SCHEMA}',db_name)
    
    search_db_sql += " and (" + column_name + ") "

    if column_type != 'None':
        search_db_sql += " and b.name = '" + column_type + "'"
        
    if table_name != 'None':
        search_db_sql += " and d.name = '" + table_name + "'"

    if column_len != 'None':
        search_db_sql += " and a.length = " + column_len 
    
    search_db_sql += " order by d.name,a.colorder"
    cursor.execute(search_db_sql)
    rs_table_list = cursor.fetchall()

    return rs_table_list

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
'''




def query_meta_data(table_list,target_db):
    
    if table_list[0:1] == ',':
        table_list = table_list[1:]

    sql = "SELECT lower(a.name) as ref_table, lower(b.name) as ref_column ,c.name as typename ,CONVERT(VARCHAR(50),b.precision) precision ,CONVERT(VARCHAR(50),b.scale) scale ,CONVERT(VARCHAR(50),b.max_length) max_length ,b.is_nullable nullable FROM sys.all_objects a inner join sys.all_columns b on a.object_id= b.object_id inner join sys.systypes c on b.system_type_id = c.xtype WHERE a.name in (" + table_list +") ORDER BY 1,2"

    with UseSqlserverDB(target_db) as cursor:
        return query(cursor,sql)
