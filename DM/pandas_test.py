import ACCT
import pandas as pd
##import DBOperator


def merge (raw1,raw2,raw3,contract,writer):

    raw1 = raw1.fillna('null')
    raw2 = raw2.fillna('null')
    raw3 = raw3.fillna('null')

    gap = pd.merge(raw1,raw2,on = ['table_schema','table_name','column_name'],how='outer')
    gap = pd.merge(gap,raw3,on = ['table_schema','table_name','column_name'],how='outer')

    for index, row in gap.iterrows():
                    
        if row[4] == row[9] == row[14] and row[5] == row[10] == row[15] and row[6] == row[11] == row[16] and row[7] == row[12] == row[17]:
            gap = gap.drop(index)
    
    gap.to_excel(writer,sheet_name = contract)
    writer.save()

###print(df_ms)


###df_ms.loc[df_ms['table_name'] == 'test']
if __name__ == '__main__':

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name"
    '''
    
    df_co = DBOperator.queryDMUsePandas(query,ACCT.qa_co)
    df_ms = DBOperator.queryDMUsePandas(query,ACCT.qa_ms)
    '''

    writer = pd.ExcelWriter('gap.xlsx')

    raw1 = pd.read_excel('test.xlsx', sheet_name ='QA')
    raw2 = pd.read_excel('test.xlsx', sheet_name ='UAT')
    raw3 = pd.read_excel('test.xlsx', sheet_name ='Prod')

    merge(raw1,raw2,raw3,'CO',writer)

    




    '''
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

