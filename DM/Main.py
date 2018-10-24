from SQLSERVERDB import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError
import ACCT

def main(sql_txt):

    try:
        """Display the contents of the log file as a HTML table."""
        with UseSqlserverDB(ACCT.config) as cursor:
            
            cursor.execute(sql_txt)
            contents = cursor.fetchall()

            print (contents)

    except DBConnectionError as err:
        print('Is your database swithed on? Error:', str(err))
    except CredentialsError as err:
        print('User-id/Password issues. Error:', str(err))
    except SQLError as err:
        print('Is your query correct? Error:',str(err))
    except Exception as err:
        print ('Something went wrong:', str(err))
    return "Error"

if __name__ == '__main__':

    _TEST_SQL = "SELECT TOP 2 * FROM [CO_HF_MART].[dbo].[D_ADDRESS] WITH(NOLOCK)"
    main(_TEST_SQL)
