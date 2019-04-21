##
# query sample data from source
##
import pandas as pd
import numpy as np
import os

import conf.acct as acct
from db_connect.sqlserver_db import UseSqlserverDB
import tool.query_metadata as query_metadata

os.system("")
TARGET_DB = acct.PROD_CO_HF_MART
TABLE_LIST = ['VW_DRAW_QUOTA']

if __name__ == '__main__':

    with UseSqlserverDB(TARGET_DB) as cursor:

        metadata_list = query_metadata.query_metadata(cursor)

        for item in metadata_list:
            table_name = item[0]
            column_name_str = str(item[1])
            if (column_name_str.endswith('_KEY') == False and column_name_str.endswith('_NB') == False and column_name_str.endswith('_DT') == False and column_name_str.endswith('_IND') == False and column_name_str.endswith('_ID') == False and column_name_str.endswith('_DTM') == False and column_name_str.endswith('_AMT') == False and column_name_str.endswith('_QTY') == False and column_name_str.endswith('_CNT') == False and column_name_str.endswith('_FLG') == False and column_name_str.endswith('_CD') == False and column_name_str.endswith('_YR') == False and column_name_str.endswith('_NUM') == False and column_name_str.endswith('_ENCRYPTED') == False and column_name_str.endswith('_NO') == False):
                check_sql = "SELECT TOP 100 " + column_name_str + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name_str + " LIKE '%<<translatable%'"
                #print("Checking "+table_name+"."+column_name_str)
                cursor.execute(check_sql)
                rs_trans = cursor.fetchall()
                if len(rs_trans) > 0:
                    print ("\n\033[32m" + table_name + "." + column_name_str + "\033[0m has un-translate string, please verify. SELECT TOP 100 " + column_name_str + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name_str + " LIKE '%<<translatable%'\n")
    
    print("\nSearching completed.")

