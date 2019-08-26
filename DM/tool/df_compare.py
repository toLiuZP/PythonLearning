import numpy as np
import pandas as pd


def has_gap(df1, df2, object_str:str):

    title = ["ID","VALUE"]
    df1.columns = title
    df2.columns = title

    merged_df = pd.merge(df1, df2, on = ["ID"], how = 'outer')

    is_same = True

    for index, row in merged_df.iterrows():
        if row[1] != row[2]:
            is_same = False
            if str(row[1]) != 'nan' and str(row[2]) != 'nan':
                print('[KEY: \033[32m' + str(row[0]) + "\033[0m] in source it's value is \033[33m" + str(row[1]) + "\033[0m, but in target, it's \033[33m" + str(row[2]) + "\033[0m")
            elif str(row[1]) == 'nan':
                print("[KEY: \033[32m" + str(row[0]) + "\033[0m, value: \033[33m" + str(row[2]) + "\033[0m] only exists in target schema.")
            elif str(row[2]) == 'nan':
                print("[KEY: \033[32m" + str(row[0]) + "\033[0m, value: \033[33m" + str(row[1]) + "\033[0m] only exists in source schema.")  

    if is_same == True:
        print("Target's \033[34m" + object_str + "\033[0m is same as source")