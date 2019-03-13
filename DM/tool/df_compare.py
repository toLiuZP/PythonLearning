import numpy as np
import pandas as pd


def has_gap(df1, df2, object_str:str):
    merged_df = pd.merge(df1, df2, on = ["ID"], how = 'outer')

    is_same = True

    for index, row in merged_df.iterrows():
        if row[1] != row[2]:
            is_same = False
            if str(row[1]) != 'nan' and str(row[2]) != 'nan':
                print('[KEY: ' + str(row[0]) + "] in source it's value is " + str(row[1]) + " , but in target, it's " + str(row[2]))
            elif str(row[1]) == 'nan':
                print("[KEY: " + str(row[0]) + ", value: " + str(row[2]) + "] only exists in target schema.")
            elif str(row[2]) == 'nan':
                print("[KEY: " + str(row[0]) + ", value: " + str(row[1]) + "] only exists in source schema.")  

    if is_same == True:
        print("Target's " + object_str + " is same as source")