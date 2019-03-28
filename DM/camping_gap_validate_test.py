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
#         a.attr_id
#         ,a.attr_name
#     FROM 
#         p_prd p 
#         LEFT JOIN
#         p_prd pp on pp.prd_id = p.parent_id and p.prd_rel_type = 3 -- Child
#         LEFT JOIN 
#         p_prd_attr pa ON pa.prd_id = COALESCE( pp.prd_id, p.prd_id )
#         LEFT JOIN 
#         d_attr a ON a.attr_id = pa.attr_id
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
import os

import conf.acct_oracle as acct_oracle
from db_connect.oracle_db import UseOracleDB
from tool.df_compare import has_gap

CURRENT_DB = acct_oracle.PROD_US
SCHEMA = 'LIVE_VA'
SEED_FILE = '.\seed\TX_CAMPING_CFG.xlsx'

os.system("")

with UseOracleDB(CURRENT_DB) as cursor:

    # 1. Verify if C_CUST_HFPROFILE has data. Impact D_CUSTOMER and D_CUSTOMER_ADDRESS
    has_customer_hfprofile = "SELECT * FROM " + SCHEMA + ".C_CUST_HFPROFILE WHERE ID > 1 AND ROWNUM < 2"
    cursor.execute(has_customer_hfprofile)
    row = cursor.fetchall()
    if len(row) == 0:
        print("C_CUST_HFPROFILE is empty. Please comment customer number and birthday")
    else:
        print("Please use hfprofile and load customer number and birthday")

    # 3. Verify what occupant type this contract has.

    inquery_occupant_sql = "select ID, NAME from " + SCHEMA + ".P_ADMISSION_TYPE where id in (select ADMISSION_TYPE_ID from " + SCHEMA + ".P_ADMISSION_PRD_CAT) order by 1"

    cursor.execute(inquery_occupant_sql)
    row = cursor.fetchall()

    if len(row) == 0:
        print(SCHEMA + "'s occupant type is null.")
    else:
        occupant_type_seed = pd.read_excel(SEED_FILE,sheet_name = "P_ADMISSION_PRD_CAT")
        occupant_type_return = pd.DataFrame(row)
        has_gap(occupant_type_seed,occupant_type_return,"Occupant type")

    # 4. Verify ticket types

    inquery_ticket_sql = "select ID, NAME from " + SCHEMA + ".P_ADMISSION_TYPE where id in (select ADMISSION_TYPE_ID from " + SCHEMA + ".O_TICKET_QUANTITY) order by 1"

    cursor.execute(inquery_ticket_sql)
    row = cursor.fetchall()

    if len(row) == 0:
        print(SCHEMA + "'s ticket type is null.")
    else:        
        ticket_type_seed = pd.read_excel(SEED_FILE,sheet_name = "O_TICKET_QUANTITY")
        ticket_type_return = pd.DataFrame(row)
        has_gap(ticket_type_seed,ticket_type_return,"ticket type")

    # 5. Verify site attributes.

    inquery_site_attr_sql = "SELECT DISTINCT a.attr_id AS ID, a.attr_name FROM " + SCHEMA + ".p_prd p LEFT JOIN " + SCHEMA + ".p_prd pp on pp.prd_id = p.parent_id and p.prd_rel_type = 3 LEFT JOIN " + SCHEMA + ".p_prd_attr pa ON pa.prd_id = NVL( pp.prd_id, p.prd_id ) LEFT JOIN " + SCHEMA + ".d_attr a ON a.attr_id = pa.attr_id WHERE p.product_cat_id = 3 AND pa.active_ind = 1 AND pa.deleted_ind = 0 order by a.attr_id, a.attr_name"

    cursor.execute(inquery_site_attr_sql)
    row = cursor.fetchall()

    if len(row) == 0:
        print(SCHEMA + "'s site attributes is null.")
    else:
        site_attr_seed = pd.read_excel(SEED_FILE,sheet_name = "SITE_ATTRIBUTES")
        site_attr_return = pd.DataFrame(row)
        has_gap(site_attr_seed,site_attr_return,"Site Attributes")
    
    



    
        

