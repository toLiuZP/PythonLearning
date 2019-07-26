import os
import sys
import sqlparse
sys.path.append(os.getcwd())
from tool.tool import file_name 


sql = '''
create table [RPT_TRANSACTION_SALES] (  [LICENSE_SALES_KEY] bigint IDENTITY(1,1) NOT NULL ,   [TRANSACTION_DTM] datetime  NULL ,   [TRANSACTION_DATE_KEY] bigint  NULL ,   [SALES_CHANNEL_NM] varchar(50)  NULL ,   [OUTLET_ID] varchar(10)  NULL ,   [OUTLET_NM] varchar(50)  NULL ,   [OUTLET_TYPE_NM] varchar(50)  NULL ,   [AGENT_ID] int  NULL ,   [AGENT_NM] varchar(35)  NULL ,   [TRANSACTION_DETAIL_ID] bigint  NULL ,   [ITEM_ID] int  NULL ,   [ITEM_NB] varchar(4)  NULL ,   [ITEM_NM] varchar(100)  NULL ,   [ITEM_TYPE_NM] varchar(50)  NULL ,   [ITEM_SALES_TYPE_NM] varchar(100)  NULL ,   [ITEM_CLASS_NM] varchar(50)  NULL ,   [ITEM_CATEGORY_NM] varchar(50)  NULL ,   [ITEM_SUBCATEGORY_NM] varchar(50)  NULL ,   [ITEM_RESIDENT_TYPE_NM] varchar(50)  NULL ,   [TRANSACTION_TYPE_NM] varchar(50)  NULL ,   [LICENSE_QTY] int  NULL ,   [LICENSE_TOTAL_AMT] decimal(38, 4)  NULL ,   [MART_SOURCE_ID] bigint  NULL ,   [MART_CREATED_DTM] datetime  NULL ,   [MART_MODIFIED_DTM] datetime  NULL , )ALTER TABLE RPT_TRANSACTION_SALES ADD CONSTRAINT PK_RPT_TRANSACTION_SALES PRIMARY KEY  ([LICENSE_SALES_KEY])


'''


print(sqlparse.format(sql, reindent=True, keyword_case='upper', indent_tabs = True))
#print(sqlparse.format(sql,  keyword_case='upper', indent_tabs = True))