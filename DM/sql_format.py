import os
import sys
import sqlparse
sys.path.append(os.getcwd())
from tool.tool import file_name 

sql = '.\seed\orginal.sql'



print(sqlparse.format(sql, reindent=True, keyword_case='upper', indent_tabs = True))