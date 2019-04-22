import cx_Oracle as oracle


def has_row(query, cursor):
    print(query)
    cursor.execute(query)
    row = cursor.fetchall()
    if len(row) == 0:
        return False
    else:
        return True

def inquery_single_row(query, cursor):
    print(query)
    cursor.execute(query)
    result = cursor.fetchall()
    if len(result) > 0:
        return str(result[0][0])
    else :
        return ''