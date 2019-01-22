
from SQLSERVERDB import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas
import pandas as pd

def queryDM(sql_txt:str, acct:dict):

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

def updateDM(sql:str, acct:dict):

    try:
        """Display the contents of the log file as a HTML table."""
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

def queryDMUsePandas(sql_txt:str, acct:dict):

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