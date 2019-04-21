##
# scrub data for sales demo db
##

import random

from tool.tool import clock 
import conf.acct
import db_connect.db_operator as db_operator

def replaceTexas(inputString:str):
    scrubbedString = inputString.replace('Texas','Aspira').replace('\'',' ').replace('TPWD','ASPIRA').replace('TX','ASPIRA').replace('TSPP','ASPIRA').replace('Full-Texas','ASPIRA').replace('tx-','ASPIRA-').replace('_TX','_ASPIRA').replace('sftx-','ASPIRA-').replace('tx_','ASPIRA-').replace('Tx','ASPIRA').replace('tpwd','ASPIRA')
    scrubbedString = scrubbedString.replace('Tpwd','ASPIRA').replace('tspp','ASPIRA').replace('Tspp','ASPIRA').replace('texas','ASPIRA').replace('tX','ASPIRA').replace('TPWd','ASPIRA').replace('tx','ASPIRA').replace('TEXAS','ASPIRA').replace('TwPd','ASPIRA')
    return scrubbedString

@clock
def replacePaymanetAllocationDiscountNM(acct:dict):
    print('\n' + "Start to scrub F_PAYMENT_ALLOCATION")
    query = "SELECT MART_SOURCE_ID, DISCOUNT_NM FROM F_PAYMENT_ALLOCATION WITH(NOLOCK) WHERE lower(DISCOUNT_NM) LIKE '%texas%' OR lower(DISCOUNT_NM) LIKE '%tpwd%' OR lower(DISCOUNT_NM) LIKE '%tspp%'"
    result = db_operator.query_db(query,acct)
    updateSQL = ""

    for item in result:
        awoID = item[0]
        discountName = item[1]
        if discountName !=None:
            discountName = item[1].replace('Texas','Aspira').replace('\'',' ').replace('TPWD','ASPIRA').replace('TX','ASPIRA').replace('TSPP','ASPIRA').replace('Full-Texas','ASPIRA')

        tempSQL = "UPDATE F_PAYMENT_ALLOCATION SET DISCOUNT_NM = \'" + str(discountName) + "\' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL

    db_operator.update_db(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceProduct(acct:dict):
    print('\n' + "Start to scrub D_PRODUCT")
    query = "SELECT MART_SOURCE_ID, PRODUCT_NM, PRODUCT_DSC FROM D_PRODUCT WITH(NOLOCK) WHERE lower(PRODUCT_NM) LIKE '%texas%' OR lower(PRODUCT_DSC) LIKE '%texas%' OR lower(PRODUCT_NM) LIKE '%tpwd%' OR lower(PRODUCT_NM) LIKE '%tpwd%'"
    result = db_operator.query_db(query,acct)
    updateSQL = ""

    for item in result:
        
        awoID = item[0]
        productName = item[1]
        productDESC = item[2]
        if productName !=None:
            productName = item[1].replace('Texas','Aspira').replace('\'',' ').replace('TPWD','ASPIRA').replace('TX','ASPIRA').replace('TEXAS','ASPIRA')
        if productDESC !=None:
            productDESC = item[2].replace('Texas','Aspira').replace('\'',' ').replace('TPWD','ASPIRA').replace('TX','ASPIRA').replace('TEXAS','ASPIRA')

        tempSQL = "UPDATE D_PRODUCT SET PRODUCT_NM = \'" + str(productName) + "\', PRODUCT_DSC = \'" + str(productDESC) + "\' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL

    db_operator.update_db(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceLocation(acct:dict):
    print('\n' + "Start to scrub D_LOCATION")
    query = "SELECT [MART_SOURCE_ID],[AGENCY_NM] FROM D_LOCATION WITH(NOLOCK) WHERE [LOCATION_KEY] > 0"
    result = db_operator.query_db(query,acct)
    updateSQL = ""

    for item in result:
        awoID = item[0]
        agencyName = item[1]
        if agencyName !=None:
            agencyName = item[1].replace('TX','ASPIRA')
       
        tempSQL = "UPDATE D_LOCATION SET CONTRACT_NM = 'Aspira' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL

    db_operator.update_db(updateSQL,acct)

    updateSQL = "UPDATE D_LOCATION SET AGENCY_NM = 'Aspira Parks and Wildlife' WHERE AGENCY_NM = 'TX Parks and Wildlife'"
    db_operator.update_db(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replacePass(acct:dict):
    print('\n' + "Start to scrub D_PASS")
    updateSQL = "UPDATE D_PASS SET PASS_TYPE_CD = 'Aspira', PASS_TYPE_NM = 'Aspira Pass', PASS_TYPE_DSC = 'Aspira Pass' WHERE [PASS_TYPE_CD] = 'TSPP'"
    db_operator.update_db(updateSQL,acct)

@clock
def replaceSupplier(acct:dict):
    print('\n' + "Start to scrub D_SUPPLIER.SUPPLIER_NM / SUPPLIER_DSC")

    query = "SELECT [MART_SOURCE_ID],[SUPPLIER_NM], [SUPPLIER_DSC] FROM D_SUPPLIER WITH(NOLOCK)   WHERE lower([SUPPLIER_NM]) LIKE '%texas%' OR lower([SUPPLIER_NM]) LIKE '%tpwd%' OR lower([SUPPLIER_NM]) LIKE '%tspp%' OR lower([SUPPLIER_NM]) LIKE '%tx%'   OR lower([SUPPLIER_DSC]) LIKE '%texas%' OR lower([SUPPLIER_DSC]) LIKE '%tpwd%' OR lower([SUPPLIER_DSC]) LIKE '%tspp%' OR lower([SUPPLIER_DSC]) LIKE '%tx%'"
    result = db_operator.query_db(query,acct)
    updateSQL = ""

    for item in result:
        awoID = item[0]
        supplierName = item[1]
        supplierDESC = item[2]
        if supplierName !=None:
            supplierName = item[1].replace('Texas','Aspira').replace('\'',' ').replace('TPWD','ASPIRA').replace('TX','ASPIRA').replace('TEXAS','ASPIRA')
        if supplierDESC !=None:
            supplierDESC = item[2].replace('Texas','Aspira').replace('\'',' ').replace('TPWD','ASPIRA').replace('TX','ASPIRA').replace('TEXAS','ASPIRA')

        tempSQL = "UPDATE D_SUPPLIER SET SUPPLIER_NM = \'" + str(supplierName) + "\', SUPPLIER_DSC = \'" + str(supplierDESC) + "\' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL

    db_operator.update_db(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceCustomerAddressKey(acct:dict):
    print('\n' + "Start to scrub D_CUSTOMER")

    query = "SELECT customer.MART_SOURCE_ID FROM D_CUSTOMER customer WITH(NOLOCK) INNER JOIN D_CUSTOMER_ADDRESS addr WITH(NOLOCK) ON addr.CUSTOMER_ADDRESS_KEY = customer.CUSTOMER_ADDRESS_KEY WHERE addr.STATE_CD = 'TX' AND customer.CUSTOMER_ADDRESS_KEY > 0"
    result = db_operator.query_db(query,acct)
    updateSQL = ""
    count = 0

    for item in result:
        
        awo_id = item[0]
        addressKey = str(random.randint(1,2147870))
        tempSQL = "UPDATE D_CUSTOMER SET CUSTOMER_ADDRESS_KEY = " + addressKey + ", MAILING_CUSTOMER_ADDRESS_KEY = " + addressKey + " WHERE MART_SOURCE_ID = " + str(awo_id) + ";"
        updateSQL = updateSQL + tempSQL
        count += 1

        if count == 10000:
            db_operator.update_db(updateSQL,acct)
            count = 0
    
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceD_User(acct:dict):

    print('\n' + "Start to scrub D_USER")

    query = "SELECT MART_SOURCE_ID, USER_NM FROM D_USER WITH(NOLOCK) WHERE LOWER(USER_NM) LIKE '%texas%' OR LOWER(USER_NM) LIKE '%tpwd%' OR LOWER(USER_NM) LIKE '%tspp%' OR LOWER(USER_NM) LIKE '%tx%'"

    result = db_operator.query_db(query,acct)

    updateSQL = ""

    for item in result:
        
        awoID = item[0]
        userName = item[1]

        if userName !=None:
            userName = replaceTexas(userName)
        
        tempSQL = "UPDATE D_USER SET USER_NM = \'" + str(userName) + "\' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL
    
    db_operator.update_db(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceR_PAYMENT_TYPE(acct:dict):

    print('\n' + "Start to scrub R_PAYMENT_TYPE")

    query = "SELECT MART_SOURCE_ID, PAYMENT_TYPE_CD, PAYMENT_TYPE_DSC FROM R_PAYMENT_TYPE WITH(NOLOCK) WHERE LOWER(PAYMENT_TYPE_CD) LIKE '%tpwd%' OR LOWER(PAYMENT_TYPE_DSC) LIKE '%tpwd%'"

    result = db_operator.query_db(query,acct)

    updateSQL = ""

    for item in result:
        
        awoID = item[0]
        paymentTypeCD = item[1]
        paymentTypeDesc = item[2]

        if paymentTypeCD !=None:
            paymentTypeCD = replaceTexas(paymentTypeCD)
        if paymentTypeDesc !=None:
            paymentTypeDesc = replaceTexas(paymentTypeDesc)
        
        tempSQL = "UPDATE R_PAYMENT_TYPE SET PAYMENT_TYPE_CD = \'" + str(paymentTypeCD) + "\', PAYMENT_TYPE_DSC = \'" + str(paymentTypeDesc) + "\' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL
    
    db_operator.update_db(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceB_GIFT_CARD_USAGE(acct:dict):

    print('\n' + "Start to scrub B_GIFT_CARD_USAGE")

    query = "SELECT GIFT_CARD_ITEM_KEY, USAGE_TRANSACTION_LOCATION_NM FROM B_GIFT_CARD_USAGE WITH(NOLOCK) WHERE LOWER(USAGE_TRANSACTION_LOCATION_NM) LIKE '%Texas State Parks%'"

    result = db_operator.query_db(query,acct)

    updateSQL = ""

    for item in result:
        
        awoID = item[0]
        locationNM = item[1]

        if locationNM !=None:
            locationNM = replaceTexas(locationNM)
        
        tempSQL = "UPDATE B_GIFT_CARD_USAGE SET USAGE_TRANSACTION_LOCATION_NM = \'" + str(locationNM) + "\' WHERE GIFT_CARD_ITEM_KEY = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL
    
    db_operator.update_db(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceB_USER_ROLE_LOCATION(acct:dict):

    print('\n' + "Start to scrub B_USER_ROLE_LOCATION")

    updateSQL = "UPDATE B_USER_ROLE_LOCATION SET LOCATION_NM = 'Aspira State Park'"

    db_operator.update_db(updateSQL,acct)

@clock
def replaceD_DAILY_ENTRANCE(acct:dict):

    print('\n' + "Start to scrub D_DAILY_ENTRANCE")

    updateSQL = "UPDATE D_DAILY_ENTRANCE SET FACILITY_NM = 'Aspira State Park'"

    db_operator.update_db(updateSQL,acct)

@clock
def replaceD_PERMIT(acct:dict):

    print('\n' + "Start to scrub D_PERMIT")

    updateSQL = "UPDATE D_PERMIT SET FACILITY_NM = 'Aspira State Park'"

    db_operator.update_db(updateSQL,acct)

@clock
def replaceD_SITE(acct:dict):

    print('\n' + "Start to scrub D_SITE")

    updateSQL = "UPDATE D_SITE SET FACILITY_NM = 'Aspira State Park', AGENCY_NM = 'Aspira'"

    db_operator.update_db(updateSQL,acct)

@clock
def replaceD_STORE(acct:dict):

    print('\n' + "Start to scrub D_STORE")

    updateSQL = "UPDATE D_STORE SET LOCATION_CLASS_NM = 'Administration'"

    db_operator.update_db(updateSQL,acct)

@clock
def replacD_LOCATION_FacilityName(acct:dict):

    print('\n' + "Start to D_LOCATION.FACILITY_NM")

    allFacilityNameQuery = "SELECT DISTINCT [FACILITY_NM] FROM [CO_HF_MART].[dbo].[D_LOCATION] WITH(NOLOCK) WHERE FACILITY_NM LIKE '%Park%' AND FACILITY_NM NOT LIKE '%Store%' AND FACILITY_NM NOT LIKE '%TEST%' AND FACILITY_NM NOT LIKE '%www%' AND FACILITY_NM NOT LIKE '%(%' UNION SELECT DISTINCT [FACILITY_NM] FROM [KS_HF_MART].[dbo].[D_LOCATION] WITH(NOLOCK) WHERE FACILITY_NM LIKE '%Park%' AND FACILITY_NM NOT LIKE '%Store%' AND FACILITY_NM NOT LIKE '%TEST%' AND FACILITY_NM NOT LIKE '%www%' AND FACILITY_NM NOT LIKE '%(%'   UNION SELECT DISTINCT [FACILITY_NM] FROM [MS_HF_MART].[dbo].[D_LOCATION] WITH(NOLOCK) WHERE FACILITY_NM LIKE '%Park%' AND FACILITY_NM NOT LIKE '%Store%' AND FACILITY_NM NOT LIKE '%TEST%' AND FACILITY_NM NOT LIKE '%www%' AND FACILITY_NM NOT LIKE '%(%'  UNION   SELECT DISTINCT [FACILITY_NM] FROM [ASPIRA_SALES_CAMPING_MART].[dbo].[D_LOCATION] WITH(NOLOCK) WHERE FACILITY_NM LIKE '%Park%' OR FACILITY_NM LIKE '%Area%' OR FACILITY_NM LIKE '%Site%' "

    allFacilityName = db_operator.query_db(allFacilityNameQuery,acct)

    query = "SELECT [LOCATION_KEY]        ,[FACILITY_NM]    FROM [ASPIRA_SALES_CAMPING_MART].[dbo].[D_LOCATION]   WHERE FACILITY_NM LIKE '%Park%' OR FACILITY_NM LIKE '%Area%' OR FACILITY_NM LIKE '%Site%' "

    result = db_operator.query_db(query,acct)

    updateSQL = ""

    for item in result:
       
        key = item[0]
        faciltiy_NM = item[1]

        if faciltiy_NM !=None:
            faciltiy_NM = allFacilityName[random.randint(0,len(allFacilityName)-1)][0]
        
        tempSQL = "UPDATE D_LOCATION SET FACILITY_NM = \'" + str(faciltiy_NM) + "\' WHERE LOCATION_KEY = " +str(key) + ";"
        updateSQL = updateSQL + tempSQL
    
    db_operator.update_db(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')


@clock
def replaceXXX_MESSAGE(acct:dict):

    message_table_ls = ['B_CUSTOMER_MESSAGE','B_LOCATION_MESSAGE','B_ORDER_MESSAGE','B_SITE_MESSAGE']

    for table_nm in message_table_ls:

        print('\n' + "Start to scrub " + str(table_nm))
        query = "SELECT MART_SOURCE_ID, MESSAGE_TXT FROM " + str(table_nm) + " WITH(NOLOCK) WHERE LOWER(MESSAGE_TXT) LIKE '%texas%' OR LOWER(MESSAGE_TXT) LIKE '%tpwd%' OR LOWER(MESSAGE_TXT) LIKE '%tx%' OR LOWER(MESSAGE_TXT) LIKE '%tspp%'"
        result = db_operator.query_db(query,acct)
        updateSQL = ""
        for item in result:
            mart_source_id = item[0]
            message_txt = item[1]

            if message_txt !=None:
                message_txt = replaceTexas(message_txt)
            
            tempSQL = "UPDATE " + str(table_nm) + " SET MESSAGE_TXT = \'" + str(message_txt) + "\' WHERE MART_SOURCE_ID = " +str(mart_source_id) + ";"
            updateSQL = updateSQL + tempSQL

        db_operator.update_db(updateSQL,acct)
        print("Scrubbed " + str(len(result)) + ' rows')


