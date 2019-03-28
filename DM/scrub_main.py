import scrub_camping
#import scrub_hf
import conf.acct as acct

     

if __name__ == '__main__':

    current_acct = acct.UAT_CAMPING_SALES
    ''' HF Sales Demo '''
    ##scrub_hf.backupProduct()
    ##mixProduct()
    ##scrub_hf.replaceProduct()
    ##scrub_hf.replaceStoreAddressKey()
    ##scrub_hf.replaceStore()
    ##scrub_hf.revertStore()


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

    '''
    scrub_camping.replaceProduct(current_acct)
    scrub_camping.replacePaymanetAllocationDiscountNM(current_acct)
    scrub_camping.replaceLocation(current_acct)
    scrub_camping.replacePass(current_acct)
    scrub_camping.replaceSupplier(current_acct)
    scrub_camping.replaceCustomerAddressKey(current_acct)
    
    scrub_camping.replaceD_User(current_acct)
    scrub_camping.replaceR_PAYMENT_TYPE(current_acct)
    scrub_camping.replaceB_GIFT_CARD_USAGE(current_acct)
    scrub_camping.replaceB_USER_ROLE_LOCATION(current_acct)
    scrub_camping.replaceD_DAILY_ENTRANCE(current_acct)
    scrub_camping.replaceD_PERMIT(current_acct)
    scrub_camping.replaceD_SITE(current_acct)
    scrub_camping.replaceD_STORE(current_acct)
    scrub_camping.replacD_LOCATION_FacilityName(current_acct)
    '''
    scrub_camping.replaceXXX_MESSAGE(current_acct)
