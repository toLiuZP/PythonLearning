import HF_Scrub
import CAMP_Scrub
import ACCT

     

if __name__ == '__main__':

    current_acct = ACCT.dev_tx
    ''' HF Sales Demo '''
    ##Scrub.backupProduct()
    ##mixProduct()
    ##Scrub.replaceProduct()
    ##Scrub.replaceStoreAddressKey()
    ##Scrub.replaceStore()
    ##Scrub.revertStore()


    ''' CAMP Sales Demo '''
    '''

    UPDATE D_LOCATION SET AGENCY_NM = 'Aspira Parks and Wildlife' WHERE AGENCY_NM = 'TX Parks and Wildlife'

        Handled 
            D_PRODUCT
            F_PAYMENT_ALLOCATION.DISCOUNT_NM
            D_LOCATION
            D_PASS
            D_SUPPLIER.SUPPLIER_NM / SUPPLIER_DSC



        D_USER
        R_PAYMENT_TYPE
        B_GIFT_CARD_USAGE.USAGE_TRANSACTION_LOCATION_NM
        B_USER_ROLE_LOCATION.LOCATION_NM
        D_DAILY_ENTRANCE.FACILITY_NM
        D_PERMIT.FACILITY_NM
        D_SITE.AGENCY_NM / FACILITY_NM
        D_STORE ???
        need check UAT
        F_PURCHASE_ORDER_ITEM.SUPPLIER_PRODUCT_CD
        R_TAX_TYPE

    '''
    ##CAMP_Scrub.replaceProduct(current_acct)
    ##CAMP_Scrub.replacePaymanetAllocationDiscountNM(current_acct)
    ##CAMP_Scrub.replaceLocation(current_acct)
    ##CAMP_Scrub.replacePass(current_acct)
    ##CAMP_Scrub.replaceSupplier(current_acct)
    ##CAMP_Scrub.replaceCustomerAddressKey(current_acct)
    
    
    
    ## LiuZP start work from 12/17/2018
    ##CAMP_Scrub.replaceD_User(current_acct)
    CAMP_Scrub.replaceR_PAYMENT_TYPE(current_acct)

    
