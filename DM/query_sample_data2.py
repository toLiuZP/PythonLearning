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
schema_list = ['LIVE_MS','LIVE_TX','LIVE_CO','LIVE_KS','LIVE_NY','LIVE_OH']
#schema_list = ['LIVE_MS','LIVE_TX','LIVE_CO_UAT2','LIVE_KS','LIVE_NY','LIVE_OH']

base_file = ".\output\sample" + re.sub(r'[^0-9]','',str(datetime.datetime.now())) + ".xlsx"

writer = pd.ExcelWriter(base_file)

with UseOracleDB(CURRENT_DB) as cursor:

    for item in schema_list:
            inquery_sql = "SELECT * FROM " + str(item) + ".D_LOC_HIERARCHY ORDER BY 1 ASC"
            cursor.execute(inquery_sql)
            row = cursor.fetchall()
        
            title = [i[0] for i in cursor.description]

            df = pd.DataFrame(row)
            df.columns = title
            df.to_excel(writer,sheet_name = item)

writer.save()
        


