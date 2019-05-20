""" Time how long a function run.
"""
import timeit
import os
import time
import sys

os.system("")

def clock(func):
    def clocked(*args):
        t0 = timeit.default_timer()
        result = func(*args)
        elapsed = timeit.default_timer() - t0
        name = func.__name__
        ##arg_str = ', '.join(repr(arg) for arg in args)
        print('%s used [%0.8fs]' % (name, elapsed))
        return result
    return clocked

def file_name(file_name:str,suffix:str)->str:
    nameTime = time.strftime('%Y%m%d%H%M%S')
    excelName = '.\output\\' + file_name + '_' + nameTime + '.' + suffix
    return excelName

