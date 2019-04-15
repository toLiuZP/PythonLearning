from db_connect.sqlserver_db import UseSqlserverDB, DBConnectionError, CredentialsError, SQLError, UseSqlserverDBPandas

def inquery_single_row(query, cursor):

    print(query)    
    
    cursor.execute(query)
    result = cursor.fetchall()
    if len(result) > 0:
        return str(result[0][0])
    else :
        return ''




    '''for item in result:
        value = item[0]
        '''
