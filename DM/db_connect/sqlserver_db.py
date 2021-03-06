import pymssql

class DBConnectionError(Exception):
    pass

class CredentialsError(Exception):
    pass

class SQLError(Exception):
    pass

class UseSqlserverDB:

    def __init__(self, config:dict) -> None:
        self.configuration = dict(config)

    def __enter__(self) -> 'cursor':
        try:
            self.conn = pymssql.connect(**self.configuration)
            self.cursor = self.conn.cursor()
            return self.cursor
        except pymssql.InterfaceError as err:
            raise DBConnectionError(err)
        except pymssql.ProgrammingError as err:
            raise CredentialsError(err)
        
    def __exit__(self,exc_type, exc_value, exc_trace) -> None:
        self.conn.commit()
        self.cursor.close()
        self.conn.close()
        if exc_type is pymssql.ProgrammingError:
            raise SQLError(exc_value)
        elif exc_type:
            raise exc_type(exc_value)
        
class UseSqlserverDBPandas:

    def __init__(self, config:dict) -> None:
        self.configuration = dict(config)

    def __enter__(self) -> 'cursor':
        try:
            self.conn = pymssql.connect(**self.configuration)
            return self.conn
        except pymssql.InterfaceError as err:
            raise DBConnectionError(err)
        except pymssql.ProgrammingError as err:
            raise CredentialsError(err)

    def __exit__(self,exc_type, exc_value, exc_trace) -> None:
        self.conn.commit()
        self.conn.close()
        if exc_type is pymssql.ProgrammingError:
            raise SQLError(exc_value)
        elif exc_type:
            raise exc_type(exc_value)


def query_first_value(cursor,sql):
    cursor.execute(sql)
    rs = cursor.fetchall()
    if len(rs) > 0:
        return rs[0][0]
    else:
        return False


def has_data(cursor,sql):
    cursor.execute(sql)
    rs = cursor.fetchall()
    return len(rs) > 0
    

def query(cursor,sql):
    cursor.execute(sql)
    rs = cursor.fetchall()
    return rs
    
def execute(cursor,sql):
    cursor.execute(sql)
