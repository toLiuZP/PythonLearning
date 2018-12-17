import DBOperator
import random

def revertStore():

    revertStore = "UPDATE D_STORE SET STORE_NM = STORE_NM_BACKUP, VENDOR_NM = VENDOR_NM_BACKUP "

    DBOperator.updateDM(revertStore)

'''

def mixProduct():

        queryProduct = "SELECT PRODUCT_CD, PRODUCT_NM ,PRODUCT_DSC ,PRODUCT_CATEGORY_NM ,PRODUCT_GROUP_NM ,PRODUCT_CATEGORY_NM ,PRODUCT_SUBCATEGORY_NM, AWO_ID  FROM D_PRODUCT WITH(NOLOCK)"

        print("Query source begin")

        sample_result = Scrub.querySampleProduct(queryProduct)
        target_result = Scrub.queryTargetProduct(queryProduct)

        count = 0 

        for item in target_result:
            
            awo_id = item[7]
            ##print(awo_id)
            match_ind = True
            while match_ind:
                sourceid = random.randint(0,len(sample_result)-1)
                if item[3] == sample_result[sourceid][3] and item[5] == sample_result[sourceid][5] and item[6] == sample_result[sourceid][6]:
                    Scrub.scrubProduct(awo_id,sample_result[sourceid])
                    del sample_result[sourceid]
                    print(count)
                    count = count + 1
                    match_ind = False
'''
def replaceProduct():

    queryProduct = "SELECT AWO_ID, PRODUCT_NM, PRODUCT_DSC FROM D_PRODUCT WITH(NOLOCK) WHERE PRODUCT_NM LIKE '%Kansas%' OR PRODUCT_DSC LIKE '%Kansas%' OR PRODUCT_NM LIKE '%KS%' OR PRODUCT_NM LIKE '%Ks%'"

    product_result = DBOperator.queryDM(queryProduct)

    updateSQL = ""

    for item in product_result:
        
        awo_id = item[0]
        product_nm = item[1].replace('Kansas','Aspira').replace('\'',' ').replace('KANSAS','ASPIRA').replace('KS','ASPIRA').replace('Ks','ASPIRA')
        product_dsc = item[2].replace('Kansas','Aspira').replace('\'',' ').replace('KANSAS','ASPIRA').replace('KS','ASPIRA').replace('Ks','ASPIRA')

        tempSQL = "UPDATE D_PRODUCT SET PRODUCT_NM = \'" + product_nm + "\', PRODUCT_DSC = \'" + product_dsc + "\' WHERE AWO_ID = " +str(awo_id) + ";"
        updateSQL = updateSQL + tempSQL

    DBOperator.updateDM(updateSQL)
    print("Updated Product name and descrption")

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