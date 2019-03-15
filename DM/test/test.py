#-*- coding:utf-8 -*-
 
from pandas import DataFrame
import pandas as pd
import numpy as np
import os

os.system("")


if __name__ == "__main__":

    name = "test"
    key = "123"

    print("[KEY: \033[32m"  + name + "\033[0m, value: 123 ] only exists in target schema.")

    print("[KEY: \033[31m{}\033[0m, value: {} ] only exists in target schema.".format(name,key))

    '''34

    df = pd.read_excel("test.xlsx")
    #df.loc['Row_sum'] = df.apply(lambda x: x.sum())
    
    print(df)
    print(df.count())
    

    if df.iloc[0,0] != -1:
        print("table xxx does not have -1 key, please verify.")

    null_check = df.count()

    #df.loc['Row_sum'] = df.apply(lambda x: x.sum())
    #print(df)
    #print("test")

    
    for index in null_check.index:
        if null_check[index] == 0:
            print(str(index) + " is all empty, please check.")
    

    for column_name in df.columns:
        if str(column_name).endswith("_KEY") == False:
            df = df.drop(column_name, 1)
    
    df.loc['Row_sum'] = df.apply(lambda x: (x+1).sum())
    for index in df.loc['Row_sum'].index:
        if df.loc['Row_sum'][index] == 0:
            print(str(index) + " is all -1, please check.")
    
    #print(df)
    '''
