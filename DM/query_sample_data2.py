import datetime
import re
import os
import numpy as np
import pandas as pd
import cx_Oracle as oracle

from db_connect.oracle_db import UseOracleDB
import conf.acct_oracle as acct_oracle

CURRENT_DB = acct_oracle.PROD_US
RETURN_LIMIT = 101
schema_list = []

base_file = ".\output\sample" + re.sub(r'[^0-9]','',str(datetime.datetime.now())) + ".xlsx"

writer = pd.ExcelWriter(base_file)

with UseOracleDB(CURRENT_DB) as cursor:

    for item in schema_list:
            owner = item[0]
            table_name = item[1]

            inquery_sql = "SELECT * FROM " + str(item) + ".D_LOC_HIERACHAY ORDER BY 1 ASC"
            cursor.execute(inquery_sql)
            row = cursor.fetchall()

            if len(row) == 0:
                print(table_name + " is empty.")
            else:
                title = [i[0] for i in cursor.description]

                df = pd.DataFrame(row)
                df.columns = title
                df.to_excel(writer,sheet_name = item)

writer.save()
        


