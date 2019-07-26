
##
# TODO: delete
##

def query_metadata(cursor, table_list='none'):

    metadata_list = "SELECT table_name,column_name FROM information_schema.columns WHERE table_schema = 'dbo' AND  ((table_name LIKE 'D[_]%' OR table_name LIKE 'B[_]%' OR table_name LIKE 'R[_]%' OR table_name LIKE 'F[_]%' OR table_name LIKE 'RPT[_]%') and table_name <> 'D_AUDIT_LOG') AND DATA_TYPE = 'varchar' AND CHARACTER_MAXIMUM_LENGTH > 14 ORDER BY table_name, ordinal_position"
    cursor.execute(metadata_list)
    rs_list = cursor.fetchall()
    i = 0

    if isinstance(table_list, str):
        return rs_list
    else:
        while i < len(rs_list):
            if rs_list[i][0] not in table_list:
                rs_list.pop(i)
                i -=1

            i +=1
            
            
            '''
            for item in rs_list:
            table_name = item[0]
            if table_name not in table_list:
                rs_list.remove(item)
            '''
        return rs_list
