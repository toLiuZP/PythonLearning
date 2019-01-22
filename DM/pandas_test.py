import ACCT
import pandas as pd
import DBOperator




###print(df_ms)


###df_ms.loc[df_ms['table_name'] == 'test']
if __name__ == '__main__':

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name"
    df_co = DBOperator.queryDMUsePandas(query,ACCT.qa_co)
    df_ms = DBOperator.queryDMUsePandas(query,ACCT.qa_ms)

    gap = pd.DataFrame()
    tableSet = pd.DataFrame()

    lastTableName = ''
    tableFound = False

    for row in df_co:

        columnFound = False
        if lastTableName != row[1]:
            tableSet = df_ms[df_ms.loc[df_ms['table_name'] == row[1]]]
            tableFound = tableSet.isna()

        if lastTableName == row[1] and tableFound == False:
            gap.append(row)
        
        if tableFound:
            for i in tableSet:
                if row[2] == i[2]:
                    columnFound = True
                    if row[4] != i[4] or row[5] != i[5] or row[6] != i[6] or row[7] != i[7]:
                        gap.append(row)
            
            if not(columnFound):
                gap.append(row)
                
    print(gap)

