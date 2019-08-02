import pandas as pd

message = pd.DataFrame(columns=['msg_type','table_nm','column_nm','msg'])


message =message.append(pd.DataFrame({

'msg_type':['1'],
'table_nm':['test'],
'column_nm':['tt'],
'msg':['tttttttttt']

}),ignore_index=True)
print(message['msg'])