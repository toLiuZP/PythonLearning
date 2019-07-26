##
# TODO: delete
##
import pandas as pd
import numpy as np
import os
import sys
sys.path.append(os.getcwd())

import conf.acct as acct
from db_connect.sqlserver_db import UseSqlserverDB
import tool.query_metadata as query_metadata

os.system("")
TARGET_DB = acct.UAT_CO_HF_MART
TABLE_LIST = ['B_HUNTER_EDUCATION_VERIFICATION','B_VEHICLE_ATTRIBUTES','B_VEHICLE_COOWNER','B_VEHICLE_DUPLICATE_ORDER',
'D_ACCOUNT','D_ADDRESS','D_AGE_CATEGORY','D_ATTRIBS','D_BOND_ISSUER'
]

if __name__ == '__main__':

    with UseSqlserverDB(TARGET_DB) as cursor:

        metadata_list = query_metadata.query_metadata(cursor)

        for item in metadata_list:
            table_name = item[0]
            column_name_str = str(item[1])

            if table_name in TABLE_LIST:
                continue
            
            check_sql = "SELECT TOP 1 " + column_name_str + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name_str + " LIKE '%<<translatable%'"
            #print("Checking "+table_name+"."+column_name_str)
            print(check_sql)
            cursor.execute(check_sql)
            rs_trans = cursor.fetchall()
            if len(rs_trans) > 0:
                print ("\n\033[32m" + table_name + "." + column_name_str + "\033[0m has un-translate string, please verify. SELECT TOP 100 " + column_name_str + " FROM " + table_name + " WITH(NOLOCK) WHERE " + column_name_str + " LIKE '%<<translatable%'\n")
    
    print("\nSearching completed.")

