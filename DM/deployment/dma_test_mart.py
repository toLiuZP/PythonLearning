###
# Dev Server:
# DB: DMA_MART_TEST
#   1. Drop exsiting table
#   2. Sync target db
###

import conf.acct as acct
from tool.tool import file_name,logger 
import db_connect.db_operator as db_operator

target_db = 'CO_HF_MART'
seed_file = '.\seed\gen.sql'
buildsql = ''




@logger
def clean_dma_test_mart(acct:dict):

    query = "SELECT 'DROP TABLE ' + NAME + ';' FROM sysobjects WHERE xtype = 'U' AND uid = 1 ORDER BY name"
    result = db_operator.query_db(query,acct)

    for item in result:
        deletedsql = item[0]
        db_operator.update_db(deletedsql,acct)
    
@logger
def build_target_db(acct:dict):

    data_file_group = target_db + '_DATA'
    index_file_group = target_db + '_IDX'

    with open(seed_file) as file_object:
        lines = file_object.readlines()

    for line in lines:
        buildsql += line.replace(data_file_group,'').replace(index_file_group,'')
        db_operator.update_db(buildsql,acct)


clean_dma_test_mart(acct.QA_CO_HF_MART)
build_target_db(acct.QA_CO_HF_MART)