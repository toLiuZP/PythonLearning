###
# 1. Verify if C_CUST_HFPROFILE has data. Impact D_CUSTOMER and D_CUSTOMER_ADDRESS
# 2. Confirm fiscal date.
# 3. Verify what occupant type this contract has.
# 	select * from P_ADMISSION_type where id in(
# 		select ADMISSION_type_id from P_ADMISSION_PRD_CAT
# 		)		
# 		order by 1; 
# 4. Verify ticket types
# 	select * from P_ADMISSION_type where id in(
# 		select ADMISSION_type_id from O_TICKET_QUANTITY
# 		)		
# 		order by 1; 
# 5. Verify site attributes.
# 	SELECT 
#         DISTINCT
#         a.attr_name
#     FROM 
#         live_tx.p_prd p 
#         LEFT JOIN
#         live_tx.p_prd pp on pp.prd_id = p.parent_id and p.prd_rel_type = 3 -- Child
#         LEFT JOIN 
#         live_tx.p_prd_attr pa ON pa.prd_id = COALESCE( pp.prd_id, p.prd_id )
#         LEFT JOIN 
#         live_tx.d_attr a ON a.attr_id = pa.attr_id
#         LEFT JOIN 
#         live_common.d_ref_cb_dictionary atyp ON atyp.cb_id = a.attr_type_id
#             AND atyp.cb_base_class = 'com.reserveamerica.common.data.attribute.configurable.AttributeType'
#     WHERE 
#         p.product_cat_id = 3 -- Site
#         AND
#         pa.active_ind = 1
#         AND
#         pa.deleted_ind = 0
# 		order by a.attr_name
###




import numpy as np
import pandas as pd
import cx_Oracle as oracle

from oracle_db import UseOracleDB
import acct_oracle

CURRENT_DB = acct_oracle.PROD_US
RETURN_LIMIT = 101
SEARCH_KEYS = 'SUSP'
SCHEMA = 'LIVE_KS'

writer = pd.ExcelWriter('sample.xlsx')

with UseOracleDB(CURRENT_DB) as cursor:

    # 1. Verify if C_CUST_HFPROFILE has data. Impact D_CUSTOMER and D_CUSTOMER_ADDRESS
    has_customer_hfprofile = "SELECT * FROM " + SCHEMA + ".C_CUST_HFPROFILE WHERE ID > 1 AND ROWNUM < 2"
    cursor.execute(has_customer_hfprofile)
    row = cursor.fetchall()
    if len(row) == 0:
        print("C_CUST_HFPROFILE is empty. Please comment customer number and birthday")

    # 3. Verify what occupant type this contract has.

    inquery_occupant_sql = "select * from " + SCHEMA + ".P_ADMISSION_type where id in(select ADMISSION_type_id from " + SCHEMA + ".P_ADMISSION_PRD_CAT) order by 1;"

    cursor.execute(has_customer_hfprofile)
    row = cursor.fetchall()

    if len(row) == 0:
        print(SCHEMA + "'s occupant type is null.")
    else:
        pass

    # 4. Verify ticket types

    inquery_ticket_sql = "select * from " + SCHEMA + ".P_ADMISSION_type where id in(select ADMISSION_type_id from " + SCHEMA + ".O_TICKET_QUANTITY) order by 1;"

    cursor.execute(inquery_ticket_sql)
    row = cursor.fetchall()

    if len(row) == 0:
        print(SCHEMA + "'s ticket type is null.")
    else:
        pass

    # 5. Verify site attributes.

    inquery_site_attr_sql = "select * from " + SCHEMA + ".P_ADMISSION_type where id in(select ADMISSION_type_id from " + SCHEMA + ".O_TICKET_QUANTITY) order by 1;"

    cursor.execute(inquery_site_attr_sql)
    row = cursor.fetchall()

    if len(row) == 0:
        print(SCHEMA + "'s site attributes is null.")
    else:
        pass


    
        


