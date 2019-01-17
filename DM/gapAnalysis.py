import ACCT
import DBOperator

def queryMetaData(acct:dict):

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name"
    result = DBOperator.queryDM(query,acct)

    return result    

if __name__ == '__main__':

    coMetaData = queryMetaData(ACCT.qa_co)
    salesMetaData = queryMetaData(ACCT.qa_ks)

    comparePositionInd = False

    lastTableName = ''

    for item in coMetaData:

        tableName = item[1]
        columnName = item[2]
        ordinalPosition = item[3]
        dataType = item[4]
        dataLength = item[5]
        numericScale = item[6]
        isNullable = [7]

        tableExistInd = False
        rowExistInd = False

        for row in salesMetaData:
            if tableName == row[1]:
                tableExistInd = True
                if columnName == row[2]:
                    rowExistInd = True
                    if dataType != row[4] or dataLength != row[5] or numericScale != row[6] or isNullable != row[7] :
                        print(item)
                    elif comparePositionInd == True and ordinalPosition != row[3]  :
                        print(item)
                
        if tableName != lastTableName and tableExistInd == False:
            print(tableName)
        elif tableExistInd == True and rowExistInd == False:
            print(item)


        lastTableName = tableName
        




