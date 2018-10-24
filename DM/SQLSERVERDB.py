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
        