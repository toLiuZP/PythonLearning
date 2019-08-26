""" Time how long a function run.
"""
import timeit
import os
import time
import sys
import re

os.system("")

def clock(func):
    def clocked(*args,**kw):
        start = time.time()
        result = func(*args, **kw)
        cost = time.time() - start
        print('%s used [%0.8fs]' % (func.__name__, cost))
        return result
    return clocked

def file_name(file_name:str,suffix:str)->str:
    nameTime = time.strftime('%Y%m%d %H%M%S')
    excelName = '.\output\\' + file_name + '_' + nameTime + '.' + suffix
    return excelName

def logger(func):
    def wrapper(*args, **kw):
        start = time.time()
        print("\n[INFO]  Start \033[36m=== {} ===\033[0m at {} \n\n".format(func.__name__, time.strftime("%a, %d %b %Y %H:%M:%S +0000", time.gmtime())))
        result = func(*args, **kw)
        cost = time.time() - start
        print("\n[INFO]  Completed \033[36m=== {} ===\033[0m at {} ".format(func.__name__, time.strftime("%a, %d %b %Y %H:%M:%S +0000", time.gmtime())))
        print('[INFO]  %s used [%0.8fs]' % (func.__name__, cost))
        return result
    return wrapper

def save_file(file_nm:str, contect:str):
    with open(file_nm, 'w') as file_object:
        file_object.write(contect)

def identify_backup_tables(table_nm:str) -> bool:
     return re.search(r'_tmp',table_nm) or re.search(r'_temp',table_nm) or re.search(r'_bk',table_nm) or re.search(r'_bk\d{4}',table_nm) or re.search(r'_bk\d{6}',table_nm) or re.search(r'_legacy',table_nm) or re.search(r'\d{6}',table_nm)