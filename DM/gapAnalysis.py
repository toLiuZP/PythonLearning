import ACCT
import DBOperator

def queryMetaData(acct:dict):

    query = "SELECT table_schema, table_name, column_name, ordinal_position , data_type, COALESCE(character_maximum_length,numeric_precision,datetime_precision) data_length, numeric_scale, is_nullable FROM information_schema.columns WHERE table_schema = 'dbo' ORDER BY table_name"
    result = DBOperator.queryDM(query,acct)

    return result    

if __name__ == '__main__':

    sampleMetaData = queryMetaData(ACCT.qa_co)
    targetAMetaData = queryMetaData(ACCT.qa_ms)

    comparePositionInd = False

    lastTableName = ''

    gapList = []

    for item in sampleMetaData:

        tableName = item[1]
        columnName = item[2]
        ordinalPosition = item[3]
        dataType = item[4]
        dataLength = item[5]
        numericScale = item[6]
        isNullable = item[7]

        if tableName != lastTableName:
            tableExistInd = False
        rowExistInd = False

        for row in targetAMetaData:
            if tableName == row[1]:
                tableExistInd = True
                if columnName == row[2]:
                    rowExistInd = True
                    if dataType != row[4] or dataLength != row[5] or numericScale != row[6] or isNullable != row[7] :
                        ##pass
                        print(item + row)
                    elif comparePositionInd == True and ordinalPosition != row[3]  :
                        pass
                        ##print(item,row)
                
        if tableName != lastTableName and tableExistInd == False:
            pass
            ##print(tableName)
            ##gapList.append('1',0,item)
        elif tableExistInd == True and rowExistInd == False:
            pass
            ##print(item)


        lastTableName = tableName
    ##print(gapList)
        




