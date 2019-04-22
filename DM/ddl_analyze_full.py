###
# TODO: Need to update to keep the format of spreadsheet.
###

import pandas as pd
import datetime

import conf.acct as acct
import db_connect.db_operator as DB
from tool.tool import file_name 

def merge(dev, qa, uat, contract, writer, prod='none'):
    # TODO: update rawx to Env name
    dev = dev.fillna('null')
    qa = qa.fillna('null')
    uat = uat.fillna('null')

    gap = pd.merge(dev, qa, on = ['table_schema','table_name','column_name'], how='outer')
    gap = pd.merge(gap, uat, on = ['table_schema','table_name','column_name'], how='outer')

    if isinstance(uat, str):
        for index, row in gap.iterrows():
            if row[4] == row[9] == row[14] and row[5] == row[10] == row[15] and row[6] == row[11] == row[16] \
                and row[7] == row[12] == row[17]:
                gap = gap.drop(index)
    else:
        
        
        for index, row in gap.iterrows():
            if row[4] == row[9] == row[14] and row[5] == row[10] == row[15] and row[6] == row[11] == row[16] \
                and row[7] == row[12] == row[17]:
                gap = gap.drop(index)
    
    gap.to_excel(writer,sheet_name = contract)
    writer.save()

if __name__ == '__main__':

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' AND table_name NOT LIKE 'MSpeer_%' AND table_name NOT LIKE 'MSpub_%' AND table_name NOT LIKE 'syncobj_0x%' AND table_name NOT LIKE 'sysarticle%' AND table_name NOT LIKE 'sysextendedarticlesview' AND table_name NOT LIKE 'syspublications' AND table_name <> 'sysreplservers' AND table_name <> 'sysreplservers' AND table_name <> 'sysschemaarticles' AND table_name <> 'syssubscriptions' AND table_name <> 'systranschemas' ORDER BY table_name"
    # TODO: Update to use the file name function.
    filename = file_name("DDL_GAP",".xlsx")
    writer = pd.ExcelWriter(filename)
    
    dev = DB.query_db_pandas(query, acct.QA_CO_HF_MART)
    qa = DB.query_db_pandas(query, acct.UAT_CO_HF_MART)
    uat = DB.query_db_pandas(query, acct.PROD_CO_HF_MART)

    merge(dev,qa,'CO',writer,uat)
    #merge(dev,qa,'KS',writer)
    


