import HF_Scrub
import CAMP_Scrub
import ACCT

     

if __name__ == '__main__':

    current_acct = ACCT.UAT_CAMPING_SALES
    ''' HF Sales Demo '''
    ##Scrub.backupProduct()
    ##mixProduct()
    ##Scrub.replaceProduct()
    ##Scrub.replaceStoreAddressKey()
    ##Scrub.replaceStore()
    ##Scrub.revertStore()


    ''' CAMP Sales Demo '''
    '''
        D_PRODUCT
        F_PAYMENT_ALLOCATION.DISCOUNT_NM
        D_LOCATION
        D_PASS
        D_SUPPLIER.SUPPLIER_NM / SUPPLIER_DSC
        CustomerAddressKey
        D_USER
        R_PAYMENT_TYPE
        B_GIFT_CARD_USAGE.USAGE_TRANSACTION_LOCATION_NM
        B_USER_ROLE_LOCATION.LOCATION_NM -- do not use it in Sales Demo.
        D_DAILY_ENTRANCE.FACILITY_NM -- contain Texas 
        D_PERMIT.FACILITY_NM
        D_SITE.AGENCY_NM / FACILITY_NM
        D_STORE.LOCATION_CLASS_NM
    '''


    CAMP_Scrub.replaceProduct(current_acct)
    CAMP_Scrub.replacePaymanetAllocationDiscountNM(current_acct)
    CAMP_Scrub.replaceLocation(current_acct)
    CAMP_Scrub.replacePass(current_acct)
    CAMP_Scrub.replaceSupplier(current_acct)
    ##CAMP_Scrub.replaceCustomerAddressKey(current_acct)
    CAMP_Scrub.replaceD_User(current_acct)
    CAMP_Scrub.replaceR_PAYMENT_TYPE(current_acct)
    CAMP_Scrub.replaceB_GIFT_CARD_USAGE(current_acct)
    CAMP_Scrub.replaceB_USER_ROLE_LOCATION(current_acct)
    CAMP_Scrub.replaceD_DAILY_ENTRANCE(current_acct)
    CAMP_Scrub.replaceD_PERMIT(current_acct)
    CAMP_Scrub.replaceD_SITE(current_acct)
    CAMP_Scrub.replaceD_STORE(current_acct)

    
