import numpy as np
import pandas as pd
import cx_Oracle as oracle

from oracle_db import UseOracleDB
import acct_oracle

CURRENT_DB = acct_oracle.PROD_US
RETURN_LIMIT = 101
SEARCH_KEYS = 'SUSP'

writer = pd.ExcelWriter('sample.xlsx')

with UseOracleDB(CURRENT_DB) as cursor:

    table_list = "SELECT OWNER,TABLE_NAME FROM all_tab_comments WHERE OWNER = 'LIVE_CO' AND TABLE_NAME LIKE '%" + str(SEARCH_KEYS) + "%' AND TABLE_TYPE = 'TABLE'"
    cursor.execute(table_list)
    row = cursor.fetchall()

    for item in row:
            owner = item[0]
            table_name = item[1]

            inquery_sql = "SELECT * FROM " + str(owner) + "." + str(table_name) + "  WHERE ROWNUM < " + str(RETURN_LIMIT) + " ORDER BY 1 DESC"
            cursor.execute(inquery_sql)
            row = cursor.fetchall()

            if len(row) == 0:
                print(table_name + " is empyt.")
            else:
                title = [i[0] for i in cursor.description]

                df = pd.DataFrame(row)
                df.columns = title
                df.to_excel(writer,sheet_name = table_name)

writer.save()
        


