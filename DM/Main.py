import Scrub
import random
##queryProduct = "SELECT TOP 1 PRODUCT_NM ,PRODUCT_DSC ,PRODUCT_CATEGORY_NM ,PRODUCT_GROUP_NM ,PRODUCT_CATEGORY_NM ,PRODUCT_CLASS_NM ,PRODUCT_SUBCATEGORY_NM  FROM D_PRODUCT WITH(NOLOCK)"

def updateProduct():

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


if __name__ == '__main__':


    ##Scrub.backupProduct()


    ##Scrub.queryProduct(queryProduct)
    updateProduct()


    

    