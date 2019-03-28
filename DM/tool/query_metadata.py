
def query_metadata(cursor, table_list='none'):

    metadata_list = "SELECT table_name,column_name FROM information_schema.columns WHERE table_schema = 'dbo' AND  (table_name NOT LIKE 'MSpeer_%' AND table_name NOT LIKE 'MSpub_%' AND table_name NOT LIKE 'syncobj_0x%' AND table_name NOT LIKE 'sysarticle%' AND table_name NOT LIKE 'sysextendedarticlesview' AND table_name NOT LIKE 'syspublications' AND table_name <> 'sysreplservers' AND table_name <> 'sysreplservers' AND table_name <> 'sysschemaarticles' AND table_name <> 'syssubscriptions' AND table_name <> 'systranschemas' AND table_name NOT LIKE 'O_LEGACY_%' AND table_name NOT LIKE 'QUEST_%' and table_name <> 'D_AUDIT_LOG')  ORDER BY table_name, ordinal_position"
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
