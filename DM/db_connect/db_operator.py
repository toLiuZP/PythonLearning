import pandas as pd

from db_connect.sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas


def query_db(sql_txt:str, acct:dict):
    try:
        with UseSqlserverDB(acct) as cursor:
            cursor.execute(sql_txt)
            contents = cursor.fetchall()

    except DBConnectionError as err:
        print('Is your database swithed on? Error:', str(err))
    except CredentialsError as err:
        print('User-id/Password issues. Error:', str(err))
    except SQLError as err:
        print('Is your query correct? Error:',str(err))
    except Exception as err:
        print ('Something went wrong:', str(err))
    return contents

def update_db(sql:str, acct:dict):
    try:
        with UseSqlserverDB(acct) as cursor:
            cursor.execute(sql)

    except DBConnectionError as err:
        print('Is your database swithed on? Error:', str(err))
    except CredentialsError as err:
        print('User-id/Password issues. Error:', str(err))
    except SQLError as err:
        print('Is your query correct? Error:',str(err))
    except Exception as err:
        print ('Something went wrong:', str(err))
    return "Error"

def query_db_pandas(sql_txt:str, acct:dict):
    try:
        with UseSqlserverDBPandas(acct) as conn:
            df = pd.read_sql(sql_txt,conn)

    except DBConnectionError as err:
        print('Is your database swithed on? Error:', str(err))
    except CredentialsError as err:
        print('User-id/Password issues. Error:', str(err))
    except SQLError as err:
        print('Is your query correct? Error:',str(err))
    except Exception as err:
        print ('Something went wrong:', str(err))
    return df