import cx_Oracle as oracle


def has_row(query, cursor):
    print(query)
    cursor.execute(query)
    row = cursor.fetchall()
    if len(row) == 0:
        return False
    else:
        return True