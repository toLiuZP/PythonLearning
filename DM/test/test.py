import pandas as pd

#message = pd.DataFrame(('1','test','tt','dd'), columns=['msg_type','table_nm','column_nm','msg'])


message = pd.DataFrame({

'msg_type':'1',
'table_nm':'test',
'column_nm':'tt',
'msg':'tttttttttt'

})
print(message['msg'])