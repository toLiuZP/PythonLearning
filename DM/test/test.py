import pandas as pd
'''
message = pd.DataFrame(columns=['msg_type','table_nm','column_nm','msg'])


message =message.append(pd.DataFrame({

'msg_type':['1'],
'table_nm':['test'],
'column_nm':['tt'],
'msg':['tttttttttt']

}),ignore_index=True)
print(message['msg'])
'''
'''
list_a = ['1','b','c']
test = ''
for _ in list_a:
    test = test + _
'''

import pip
from subprocess import call
 
for dist in pip.get_installed_distributions():
    call("pip install --upgrade " + dist.project_name, shell=True)

#print(test)