import numpy as np
import pandas as pd
import cx_Oracle as oracle



from oracle_db import UseOracleDB
import acct_oracle

CURRENT_DB = acct_oracle.QA3_LIVE_CO
'''
writer = pd.ExcelWriter('sample.xlsx')

table_list = "SELECT OWNER,TABLE_NAME FROM all_tab_comments WHERE OWNER = 'LIVE_CO' AND TABLE_NAME LIKE '%SUSPENSION%' AND TABLE_TYPE = 'TABLE'"
db=oracle.connect('ZL162807/LiZhi2018@awotordevqadb-scan.dev.activenetwork.com:1521/toaous3q')

cursor = db.cursor()
cursor.execute(table_list)
row = cursor.fetchall()

for item in row:
        owner = item[0]
        table_name = item[1]

        inquery_sql = "SELECT * FROM " + owner + "." + table_name + "  WHERE ROWNUM < 100 ORDER BY 1 DESC"
        cursor.execute(inquery_sql)
        row = cursor.fetchall()

        if len(row) == 0:
            print(table_name + " is empyt.")
        else:
            title = [i[0] for i in cursor.description]
            print(title)


            df = pd.DataFrame(row)

            df.columns = title

            df.to_excel(writer,sheet_name = table_name)
            writer.save()
        
cursor.close()  
db.close() 
'''

with UseOracleDB(CURRENT_DB) as cursor:

    generate_empty_validation_sql = "SELECT NAME, 'SELECT TOP 2 * FROM ' + NAME + ' WITH(NOLOCK) ORDER BY 1 ASC;' AS SQL_TEXT FROM sysobjects WHERE xtype = 'U' AND uid = 1 ORDER BY name"
    cursor.execute("select * from dual")
    
    row = cursor.fetchone ()  
    print (row)  

'''
username="king"
userpwd="king"
host="127.0.0.1"
port=1521
dbname="orcl"
#dsn=cx.makedsn(host, port, dbname)
#connection=cx.connect(username, userpwd, dsn) 

db=cx.connect('ZL162807/LiZhi2018@awotordevqadb-scan.dev.activenetwork.com:1521/toaous3q')

#conn = cx.connect('sys/password@localhost/orcl')    
cursor = db.cursor ()  
cursor.execute ("select * from dual")  
row = cursor.fetchone ()  
print (row)    
cursor.close ()  
db.close () 
'''
'''
def check_data(cursor, table_list):

    """
    " 1. Validate if column is null first.
    " 2. If columns is key, validate if it's all -1.
    " 3. If it's MART_SOURCE_ID, validate if it has duplicates.
    """

    generate_raw_list = "SELECT table_name,column_name FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name, ordinal_position"
    cursor.execute(generate_raw_list)
    rs_list = cursor.fetchall()

    for item in rs_list:
        table_name = item[0]
        column_name = item[1]

        if table_name in table_list:
            null_check_sql = "SELECT TOP 1 " + column_name + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name + " IS NOT NULL"
            cursor.execute(null_check_sql)
            rs_has_data = cursor.fetchall()
'''