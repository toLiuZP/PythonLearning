import cx_Oracle as oracle

class DBConnectionError(Exception):
    pass
    
class UseOracleDB:

    def __init__(self, config:dict) -> None:
        self.configuration = dict(config)

    def __enter__(self) -> 'cursor':
        try:
            self.conn = oracle.connect(**self.configuration)
            self.cursor = self.conn.cursor()
            return self.cursor
        except oracle.InterfaceError as err:
            raise DBConnectionError(err)

    def __exit__(self,exc_type, exc_value, exc_trace) -> None:
        self.conn.commit()
        self.cursor.close()
        self.conn.close()
        
        