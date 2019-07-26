import cx_Oracle as oracle
import pandas as pd

from db_connect.oracle_db import UseOracleDB

def has_row(query, cursor):
    #print(query)
    cursor.execute(query)
    row = cursor.fetchall()
    if len(row) == 0:
        return False
    else:
        return True

def inquery_single_row(query, cursor):
    #print(query)
    cursor.execute(query)
    result = cursor.fetchall()
    if len(result) > 0:
        return str(result[0][0])
    else :
        return ''

def query_db_pandas(sql_txt:str, server:dict):
    try:
        with UseOracleDB(server) as cursor:
            cursor.execute(sql_txt)  
            rows=cursor.fetchall()  
            df=pd.DataFrame(rows)

            title = [i[0] for i in cursor.description]
            df.columns = title

    except Exception as err:
        print ('Something went wrong:', str(err))
    return df