import ACCT
import pandas as pd
import DBOperator




###print(df_ms)


###df_ms.loc[df_ms['table_name'] == 'test']
if __name__ == '__main__':

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name"
    df_co = DBOperator.queryDMUsePandas(query,ACCT.qa_co)
    df_ms = DBOperator.queryDMUsePandas(query,ACCT.qa_ms)