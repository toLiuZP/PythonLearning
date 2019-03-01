from pandas import DataFrame
import pandas as pd
import numpy as np



if __name__ == "__main__":

    df = pd.read_excel("test.xlsx")
    #df.loc['Row_sum'] = df.apply(lambda x: x.sum())
    print(df)
    print(df.count())
