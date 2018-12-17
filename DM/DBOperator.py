
from SQLSERVERDB import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError

'''
def backupProduct():
    try:

        backupProductSQL = "UPDATE D_PRODUCT SET PRODUCT_NM_BACKUP = PRODUCT_NM, PRODUCT_DSC_BACKUP = PRODUCT_DSC, PRODUCT_CD_BACKUP = PRODUCT_CD"

        with UseSqlserverDB(ACCT.dev_sales) as cursor:
            
            cursor.execute(backupProductSQL)

    except DBConnectionError as err:
        print('Is your database swithed on? Error:', str(err))
    except CredentialsError as err:
        print('User-id/Password issues. Error:', str(err))
    except SQLError as err:
        print('Is your query correct? Error:',str(err))
    except Exception as err:
        print ('Something went wrong:', str(err))
    return "Error"
'''
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

'''
def scrubProduct(id, source):

    updateSQL = "UPDATE D_PRODUCT SET PRODUCT_NM = %s, PRODUCT_DSC = %s, PRODUCT_CD = %s WHERE AWO_ID = %s"

    try:
        """Display the contents of the log file as a HTML table."""
        with UseSqlserverDB(ACCT.dev_sales) as cursor:
            
            cursor.execute(updateSQL,(source[1],source[2],source[0],id))

    except DBConnectionError as err:
        print('Is your database swithed on? Error:', str(err))
    except CredentialsError as err:
        print('User-id/Password issues. Error:', str(err))
    except SQLError as err:
        print('Is your query correct? Error:',str(err))
    except Exception as err:
        print ('Something went wrong:', str(err))
    return "Error"
'''

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