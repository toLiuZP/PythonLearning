import cx_Oracle as oracle


def has_row(query, cursor):
    cursor.execute(query)
    row = cursor.fetchall()
    if len(row) == 0:
        return False
    else:
        return True