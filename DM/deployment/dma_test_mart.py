###
# Dev Server:
# DB: DMA_MART_TEST
#   1. Drop exsiting table
#   2. Sync target db
###

import os
import sys
sys.path.append(os.getcwd())

import conf.acct as acct
from tool.tool import file_name,logger 
import db_connect.db_operator as db_operator

target_db = "GA_CAMPING_MART"
seed_file = ".\seed\SYNC_TARGET_DB.sql"


@logger
def clean_dma_test_mart(acct:dict):

    query = "SELECT 'DROP TABLE [' + NAME + '];' FROM sysobjects WHERE xtype = 'U' AND uid = 1 ORDER BY name"
    deletedsql = ''
    result = db_operator.query_db(query,acct)

    for item in result:
        deletedsql += item[0]
    
    db_operator.update_db(deletedsql,acct)
    
@logger
def build_target_db(acct:dict):
    buildsql = ''

    with open(seed_file,encoding="utf") as file_object:
        lines = file_object.readlines()
    for line in lines:
        buildsql += line.replace(target_db,'DMA_MART_TEST').replace('GO\n','\n') #.replace('\n',' ').replace('\t',' ').

    db_operator.update_db(buildsql,acct)


clean_dma_test_mart(acct.DEV_DMA_MART_TEST)
#build_target_db(acct.DEV_DMA_MART_TEST)