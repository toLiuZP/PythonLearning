import ACCT
import pandas as pd
##import DBOperator




###print(df_ms)


###df_ms.loc[df_ms['table_name'] == 'test']
if __name__ == '__main__':

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name"
    '''
    
    df_co = DBOperator.queryDMUsePandas(query,ACCT.qa_co)
    df_ms = DBOperator.queryDMUsePandas(query,ACCT.qa_ms)
    '''

    df_co = pd.read_excel('test.xlsx', sheet_name ='co')
    df_ms = pd.read_excel('test.xlsx', sheet_name ='ms')

    df_co = df_co.fillna('null')
    df_ms = df_ms.fillna('null')

    gap = pd.merge(df_co,df_ms,on = ['table_name','column_name'],how='outer')

    for index, row in gap.iterrows():
                    
        if row[4] == row[10] and row[5] == row[11] and row[6] == row[12] and row[7] == row[13]:
            gap = gap.drop(index)


    writer = pd.ExcelWriter('gap.xlsx')
    gap.to_excel(writer,sheet_name = 'gap')
    writer.save()




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

