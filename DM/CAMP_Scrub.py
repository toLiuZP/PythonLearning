import DBOperator
import random
from LiuZP_Tool import clock 


def replaceTexas(inputString:str):

    scrubbedString = inputString.replace('Texas','Aspira').replace('\'',' ').replace('TPWD','ASPIRA').replace('TX','ASPIRA').replace('TSPP','ASPIRA').replace('Full-Texas','ASPIRA').replace('tx-','ASPIRA-').replace('_TX','_ASPIRA').replace('sftx-','ASPIRA-').replace('tx_','ASPIRA-')
    return scrubbedString

@clock
def replacePaymanetAllocationDiscountNM(acct:dict):

    print('\n' + "Start to scrub F_PAYMENT_ALLOCATION")

    query = "SELECT MART_SOURCE_ID, DISCOUNT_NM FROM F_PAYMENT_ALLOCATION WITH(NOLOCK) WHERE lower(DISCOUNT_NM) LIKE '%texas%' OR lower(DISCOUNT_NM) LIKE '%tpwd%' OR lower(DISCOUNT_NM) LIKE '%tspp%'"
    result = DBOperator.queryDM(query,acct)
    updateSQL = ""

    for item in result:
        
        awoID = item[0]
        discountName = item[1]
        if discountName !=None:
            discountName = item[1].replace('Texas','Aspira').replace('\'',' ').replace('TPWD','ASPIRA').replace('TX','ASPIRA').replace('TSPP','ASPIRA').replace('Full-Texas','ASPIRA')

        tempSQL = "UPDATE F_PAYMENT_ALLOCATION SET DISCOUNT_NM = \'" + str(discountName) + "\' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL

    DBOperator.updateDM(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceProduct(acct:dict):

    print('\n' + "Start to scrub D_PRODUCT")

    query = "SELECT MART_SOURCE_ID, PRODUCT_NM, PRODUCT_DSC FROM D_PRODUCT WITH(NOLOCK) WHERE lower(PRODUCT_NM) LIKE '%texas%' OR lower(PRODUCT_DSC) LIKE '%texas%' OR lower(PRODUCT_NM) LIKE '%tpwd%' OR lower(PRODUCT_NM) LIKE '%tpwd%'"
    result = DBOperator.queryDM(query,acct)
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

    DBOperator.updateDM(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

'''
def replaceStoreAddressKey():

    queryStore = "SELECT AWO_ID FROM D_STORE WITH(NOLOCK) WHERE AWO_ID > 0"

    store_result = DBOperator.queryDM(queryStore)

    updateSQL = ""

    for item in store_result:
        
        awo_id = item[0]

        addressKey = str(random.randint(0,4000000))

        tempSQL = "UPDATE D_STORE SET PHYS_ADDRESS_KEY = " + addressKey + ", MAIL_ADDRESS_KEY = " + addressKey + ", AWO_PHYS_ADDRESS_ID = (SELECT AWO_ID FROM D_ADDRESS WITH(NOLOCK) WHERE D_ADDRESS_KEY = " + addressKey + "),  AWO_MAIL_ADDRESS_ID = (SELECT AWO_ID FROM D_ADDRESS WITH(NOLOCK) WHERE D_ADDRESS_KEY = " + addressKey + ") WHERE AWO_ID = " + str(awo_id) + ";"
        updateSQL = updateSQL + tempSQL

    DBOperator.updateDM(updateSQL)
    print("Updated Store Address Keys")
'''

'''
def replaceStore():

    queryStore = "SELECT AWO_ID, STORE_NM, VENDOR_NM FROM D_STORE WITH(NOLOCK) WHERE AWO_ID > 0"

    store_result = DBOperator.queryDM(queryStore)

    updateSQL = ""

    for item in store_result:
        
        awo_id = item[0]
        store_nm = item[1].replace('WAL-MART','Aspira').replace('\'',' ')
        vendor_nm = item[2].replace('WAL-MART','Aspira').replace('\'',' ')

        tempSQL = "UPDATE D_STORE SET STORE_NM = \'" + store_nm + "\', VENDOR_NM = \'" + vendor_nm + "\' WHERE AWO_ID = " +str(awo_id) + ";"
        updateSQL = updateSQL + tempSQL

    DBOperator.updateDM(updateSQL)
    print("Updated Store name and Vendor Name")
'''

@clock
def replaceLocation(acct:dict):

    print('\n' + "Start to scrub D_LOCATION")

    query = "SELECT [MART_SOURCE_ID],[AGENCY_NM] FROM D_LOCATION WITH(NOLOCK) WHERE [LOCATION_KEY] > 0"
    result = DBOperator.queryDM(query,acct)
    updateSQL = ""

    for item in result:
        
        awoID = item[0]
        agencyName = item[1]
        if agencyName !=None:
            agencyName = item[1].replace('TX','ASPIRA')
       
        tempSQL = "UPDATE D_LOCATION SET CONTRACT_NM = 'Aspira' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL

    DBOperator.updateDM(updateSQL,acct)

    updateSQL = "UPDATE D_LOCATION SET AGENCY_NM = 'Aspira Parks and Wildlife' WHERE AGENCY_NM = 'TX Parks and Wildlife'"
    DBOperator.updateDM(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replacePass(acct:dict):

    print('\n' + "Start to scrub D_PASS")

    updateSQL = "UPDATE D_PASS SET PASS_TYPE_CD = 'Aspira', PASS_TYPE_NM = 'Aspira Pass', PASS_TYPE_DSC = 'Aspira Pass' WHERE [PASS_TYPE_CD] = 'TSPP'"
    DBOperator.updateDM(updateSQL,acct)

@clock
def replaceSupplier(acct:dict):

    print('\n' + "Start to scrub D_SUPPLIER.SUPPLIER_NM / SUPPLIER_DSC")

    query = "SELECT [MART_SOURCE_ID],[SUPPLIER_NM], [SUPPLIER_DSC] FROM D_SUPPLIER WITH(NOLOCK)   WHERE lower([SUPPLIER_NM]) LIKE '%texas%' OR lower([SUPPLIER_NM]) LIKE '%tpwd%' OR lower([SUPPLIER_NM]) LIKE '%tspp%' OR lower([SUPPLIER_NM]) LIKE '%tx%'   OR lower([SUPPLIER_DSC]) LIKE '%texas%' OR lower([SUPPLIER_DSC]) LIKE '%tpwd%' OR lower([SUPPLIER_DSC]) LIKE '%tspp%' OR lower([SUPPLIER_DSC]) LIKE '%tx%'"
    result = DBOperator.queryDM(query,acct)
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

    DBOperator.updateDM(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceCustomerAddressKey(acct:dict):

    print('\n' + "Start to scrub D_CUSTOMER")

    query = "SELECT customer.MART_SOURCE_ID FROM D_CUSTOMER customer WITH(NOLOCK) INNER JOIN D_CUSTOMER_ADDRESS addr WITH(NOLOCK) ON addr.CUSTOMER_ADDRESS_KEY = customer.CUSTOMER_ADDRESS_KEY WHERE addr.STATE_CD = 'TX' AND customer.CUSTOMER_ADDRESS_KEY > 0"
    result = DBOperator.queryDM(query,acct)
    updateSQL = ""

    for item in result:
        
        awo_id = item[0]
        addressKey = str(random.randint(1,2147870))
        tempSQL = "UPDATE D_CUSTOMER SET CUSTOMER_ADDRESS_KEY = " + addressKey + ", MAILING_CUSTOMER_ADDRESS_KEY = " + addressKey + ") WHERE MART_SOURCE_ID = " + str(awo_id) + ";"
        updateSQL = updateSQL + tempSQL

    DBOperator.updateDM(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceD_User(acct:dict):

    print('\n' + "Start to scrub D_USER")

    query = "SELECT MART_SOURCE_ID, USER_NM FROM D_USER WITH(NOLOCK) WHERE LOWER(USER_NM) LIKE '%texas%' OR LOWER(USER_NM) LIKE '%tpwd%' OR LOWER(USER_NM) LIKE '%tspp%' OR LOWER(USER_NM) LIKE '%tx%'"

    result = DBOperator.queryDM(query,acct)

    updateSQL = ""

    for item in result:
        
        awoID = item[0]
        userName = item[1]

        if userName !=None:
            userName = replaceTexas(userName)
        
        tempSQL = "UPDATE D_USER SET USER_NM = \'" + str(userName) + "\' WHERE MART_SOURCE_ID = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL
    
    DBOperator.updateDM(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceR_PAYMENT_TYPE(acct:dict):

    print('\n' + "Start to scrub R_PAYMENT_TYPE")

    query = "SELECT MART_SOURCE_ID, PAYMENT_TYPE_CD, PAYMENT_TYPE_DSC FROM R_PAYMENT_TYPE WITH(NOLOCK) WHERE LOWER(PAYMENT_TYPE_CD) LIKE '%tpwd%' OR LOWER(PAYMENT_TYPE_DSC) LIKE '%tpwd%'"

    result = DBOperator.queryDM(query,acct)

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
    
    DBOperator.updateDM(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceB_GIFT_CARD_USAGE(acct:dict):

    print('\n' + "Start to scrub B_GIFT_CARD_USAGE")

    query = "SELECT GIFT_CARD_ITEM_KEY, USAGE_TRANSACTION_LOCATION_NM FROM B_GIFT_CARD_USAGE WITH(NOLOCK) WHERE LOWER(USAGE_TRANSACTION_LOCATION_NM) LIKE '%Texas State Parks%'"

    result = DBOperator.queryDM(query,acct)

    updateSQL = ""

    for item in result:
        
        awoID = item[0]
        locationNM = item[1]

        if locationNM !=None:
            locationNM = replaceTexas(locationNM)
        
        tempSQL = "UPDATE B_GIFT_CARD_USAGE SET USAGE_TRANSACTION_LOCATION_NM = \'" + str(locationNM) + "\' WHERE GIFT_CARD_ITEM_KEY = " +str(awoID) + ";"
        updateSQL = updateSQL + tempSQL
    
    DBOperator.updateDM(updateSQL,acct)
    print("Scrubbed " + str(len(result)) + ' rows')

@clock
def replaceB_USER_ROLE_LOCATION(acct:dict):

    print('\n' + "Start to scrub B_USER_ROLE_LOCATION")

    updateSQL = "UPDATE B_USER_ROLE_LOCATION SET LOCATION_NM = 'Aspira State Park'"

    DBOperator.updateDM(updateSQL,acct)

@clock
def replaceD_DAILY_ENTRANCE(acct:dict):

    print('\n' + "Start to scrub D_DAILY_ENTRANCE")

    updateSQL = "UPDATE D_DAILY_ENTRANCE SET FACILITY_NM = 'Aspira State Park'"

    DBOperator.updateDM(updateSQL,acct)

@clock
def replaceD_PERMIT(acct:dict):

    print('\n' + "Start to scrub D_PERMIT")

    updateSQL = "UPDATE D_PERMIT SET FACILITY_NM = 'Aspira State Park'"

    DBOperator.updateDM(updateSQL,acct)

@clock
def replaceD_SITE(acct:dict):

    print('\n' + "Start to scrub D_SITE")

    updateSQL = "UPDATE D_SITE SET FACILITY_NM = 'Aspira State Park', AGENCY_NM = 'Aspira'"

    DBOperator.updateDM(updateSQL,acct)

@clock
def replaceD_STORE(acct:dict):

    print('\n' + "Start to scrub D_STORE")

    updateSQL = "UPDATE D_STORE SET LOCATION_CLASS_NM = 'Administration'"

    DBOperator.updateDM(updateSQL,acct)



