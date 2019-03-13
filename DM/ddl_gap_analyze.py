import pandas as pd

import acct
import db_operator as DB


def merge(raw1, raw2, contract, writer, raw3='none'):

    raw1 = raw1.fillna('null')
    raw2 = raw2.fillna('null')

    gap = pd.merge(raw1, raw2, on = ['table_schema','table_name','column_name'], how='outer')

    #gap.to_excel(writer,sheet_name = contract)
    #writer.save()

    if isinstance(raw3, str):
        for index, row in gap.iterrows():
            if row[4] == row[9] and row[5] == row[10] and row[6] == row[11] and row[7] == row[12]:
                gap = gap.drop(index)
    else:
        raw3 = raw3.fillna('null')
        gap = pd.merge(gap, raw3, on = ['table_schema','table_name','column_name'], how='outer')
        for index, row in gap.iterrows():
            if row[4] == row[9] == row[14] and row[5] == row[10] == row[15] and row[6] == row[11] == row[16] \
                and row[7] == row[12] == row[17]:
                gap = gap.drop(index)
    
    gap.to_excel(writer,sheet_name = contract)
    writer.save()

if __name__ == '__main__':

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' AND table_name NOT LIKE 'MSpeer_%' AND table_name NOT LIKE 'MSpub_%' AND table_name NOT LIKE 'syncobj_0x%' AND table_name NOT LIKE 'sysarticle%' AND table_name NOT LIKE 'sysextendedarticlesview' AND table_name NOT LIKE 'syspublications' AND table_name <> 'sysreplservers' AND table_name <> 'sysreplservers' AND table_name <> 'sysschemaarticles' AND table_name <> 'syssubscriptions' AND table_name <> 'systranschemas'ORDER BY table_name"

    writer = pd.ExcelWriter('gap.xlsx')
    
    raw1 = DB.query_db_pandas(query, acct.QA_CO_HF_MART)
    raw2 = DB.query_db_pandas(query, acct.UAT_CO_HF_MART)
    raw3 = DB.query_db_pandas(query, acct.PROD_CO_HF_MART)

    #merge(raw1,raw2,'CO',writer,raw3)
    merge(raw1,raw2,'TX',writer)
    


