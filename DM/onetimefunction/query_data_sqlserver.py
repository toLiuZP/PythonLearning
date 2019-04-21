##
# query data from mart
##

import datetime
import os
import pandas as pd
import time
import sys
sys.path.append(os.getcwd())
from db_connect.sqlserver_db import UseSqlserverDB
import conf.acct_af_source as acct
import tool.tool as tool

CURRENT_DB = acct.DEV_NJ_MIRG

nameTime = time.strftime('%Y%m%d%H%M%S')
excelName = tool.file_name('Mart_data','xlsx')

writer = pd.ExcelWriter(excelName)

with UseSqlserverDB(CURRENT_DB) as cursor:

    inquery_sql = "SELECT CASE a.[type] WHEN 'P' THEN 'Stored Procedures' WHEN 'V' THEN 'Views' WHEN 'AF' THEN 'Aggregate function' END AS 'Type', a.name, b.[definition] FROM sys.all_objects a,sys.sql_modules b WHERE a.is_ms_shipped=0 AND a.object_id = b.object_id AND a.[type] IN ('P','V','AF') order by a.[type], a.[name] ASC"
    cursor.execute(inquery_sql)
    row = cursor.fetchall()

    df = pd.DataFrame(row)
    df.columns = ["Type","Name","Definition"]
    df.to_excel(writer,sheet_name = "data")

writer.save()
        


