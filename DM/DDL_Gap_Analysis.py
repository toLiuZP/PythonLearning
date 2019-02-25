import ACCT
import pandas as pd
import DBOperator as DB


def merge (raw1,raw2,contract,writer,raw3 = 'none'):

    raw1 = raw1.fillna('null')
    raw2 = raw2.fillna('null')

    gap = pd.merge(raw1,raw2,on = ['table_schema','table_name','column_name'],how='outer')

    if raw3.__class__ == str:
        for index, row in gap.iterrows():
            if row[4] == row[9] and row[5] == row[10] and row[6] == row[11] and row[7] == row[12]:
                gap = gap.drop(index)
    else:
        raw3 = raw3.fillna('null')
        gap = pd.merge(gap,raw3,on = ['table_schema','table_name','column_name'],how='outer')
        for index, row in gap.iterrows():
            if row[4] == row[9] == row[14] and row[5] == row[10] == row[15] and row[6] == row[11] == row[16] and row[7] == row[12] == row[17]:
                gap = gap.drop(index)
    
    gap.to_excel(writer,sheet_name = contract)
    writer.save()

if __name__ == '__main__':

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' AND table_name NOT LIKE 'MSpeer_%' AND table_name NOT LIKE 'MSpub_%' AND table_name NOT LIKE 'syncobj_0x%' AND table_name NOT LIKE 'sysarticle%' AND table_name NOT LIKE 'sysextendedarticlesview' AND table_name NOT LIKE 'syspublications' AND table_name <> 'sysreplservers' AND table_name <> 'sysreplservers' AND table_name <> 'sysschemaarticles' AND table_name <> 'syssubscriptions' AND table_name <> 'systranschemas'ORDER BY table_name"

    writer = pd.ExcelWriter('gap.xlsx')
    
    raw1 = DB.queryDMUsePandas(query,ACCT.qa_tx)
    raw2 = DB.queryDMUsePandas(query,ACCT.UAT_TX)
    raw3 = DB.queryDMUsePandas(query,ACCT.qa_tx)

    merge(raw1,raw2,'TX',writer,raw3)
    #merge(raw1,raw2,'TX',writer)
    

    '''

    raw1 = DB.queryDMUsePandas(query,ACCT.qa_tx)
    raw2 = DB.queryDMUsePandas(query,ACCT.UAT_TX)
    raw3 = DB.queryDMUsePandas(query,ACCT.Prod_TX)

    #merge(raw1,raw2,'TX',writer,raw3)
    merge(raw1,raw2,'TX',writer)

    raw1 = DB.queryDMUsePandas(query,ACCT.DEV_MN)
    raw2 = DB.queryDMUsePandas(query,ACCT.UAT_MN)
    raw3 = DB.queryDMUsePandas(query,ACCT.Prod_MN)

    #merge(raw1,raw2,'TX',writer,raw3)
    merge(raw1,raw2,'MN',writer)
    '''

    '''
    raw1 = DB.queryDMUsePandas(query,ACCT.qa_co)
    raw2 = DB.queryDMUsePandas(query,ACCT.UAT_CO_HF_MART)
    raw3 = DB.queryDMUsePandas(query,ACCT.Prod_CO)

    merge(raw1,raw2,'CO',writer,raw3)
    '''
    '''
    raw1 = DB.queryDMUsePandas(query,ACCT.qa_ks)
    raw2 = DB.queryDMUsePandas(query,ACCT.UAT_KS)
    raw3 = DB.queryDMUsePandas(query,ACCT.Prod_KS)

    merge(raw1,raw2,'KS',writer,raw3)

    raw1 = DB.queryDMUsePandas(query,ACCT.qa_ms)
    raw2 = DB.queryDMUsePandas(query,ACCT.UAT_MS)
    raw3 = DB.queryDMUsePandas(query,ACCT.Prod_MS)

    merge(raw1,raw2,'MS',writer,raw3)
    
    




    
    df_co.fillna(0)
    df_ms.fillna(0)


    gap = pd.DataFrame()
    tableSet = pd.DataFrame()

    lastTableName = ''
    tableFound = False

    for index, row in df_co.iterrows():

        columnFound = False
        if lastTableName != row[1]:
            tableSet = df_ms[df_ms['table_name'] == row[1]]
            tableFound = not(tableSet.empty)

        if lastTableName != row[1] and tableFound == False:
            gap = gap.append(df_co.iloc[index,1:2], ignore_index=True)
        
        if tableFound:
            for i, r in tableSet.iterrows():
                if row[2] == r[2]:
                    columnFound = True
                    
                    if row[4] != r[4] or row[5] != r[5] or row[6] != r[6] or row[7] != r[7]:
                        gap = gap.append(df_co.iloc[index]+tableSet.iloc[i], ignore_index=True)
            
            if not(columnFound):
                gap = gap.append(df_co.iloc[index], ignore_index=True)

        lastTableName = row[1]
                
    print(gap)
    '''

