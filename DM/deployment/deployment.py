import os
import sys
sys.path.append(os.getcwd())

import conf.acct as acct
from tool.tool import file_name,logger 
import db_connect.db_operator as db_operator

DEV = acct.DEV_TX_CAMPING_MART
QA = acct.QA_TX_CAMPING_MART

#CAMPING_MART_LIST = ['CO_CAMPING_MART','DE_CAMPING_MART','GA_CAMPING_MART','IA_CAMPING_MART','KS_CAMPING_MART','MS_CAMPING_MART','NC_CAMPING_MART','NY_CAMPING_MART','OR_CAMPING_MART','PA_CAMPING_MART','TX_CAMPING_MART','UT_CAMPING_MART','VA_CAMPING_MART','VT_CAMPING_MART']
CAMPING_MART_LIST = ['GA_CAMPING_MART','IA_CAMPING_MART','KS_CAMPING_MART','MS_CAMPING_MART','NC_CAMPING_MART','NY_CAMPING_MART','OR_CAMPING_MART','TX_CAMPING_MART','UT_CAMPING_MART']

release_file = {
    '0000':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\0000_CAMPING_MART.sql',
    '1902':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\1902_CAMPING_MART.sql',
    '1903':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\1903_CAMPING_MART.sql',
    '1904':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\1904_CAMPING_MART.sql',
}

# create as initial 
#RELEASE_VERSION = ['0000','1902','1903','1904']

RELEASE_VERSION = ['1902','1903','1904']

@logger
def do_deploy(acct:dict, CAMPING_MART_LIST, RELEASE_VERSION, release_file):

    release_scripts = build_release_scripts(RELEASE_VERSION, release_file)


    for client in CAMPING_MART_LIST:
        client_scripts = release_scripts
        client_scripts = client_scripts.replace('{TARGET_CAMPING_MART}',client).replace('GO\n','\n')

        restfilename = r'.\deployment\release_scripts\\' + client + '.sql'
        with open(restfilename, 'w') as file_object:
            file_object.write(client_scripts)

        db_operator.update_db(client_scripts,acct)

@logger
def build_release_scripts(RELEASE_VERSION, release_file):

    final_script = '''USE {TARGET_CAMPING_MART}
'''

    for item in RELEASE_VERSION:
        for version in release_file:
            if item == version:

                with open(release_file[version],encoding="utf") as file_object:
                    lines = file_object.readlines()
                for line in lines:
                    final_script += line
        final_script += '\n\n'
    
    return final_script

if __name__ == '__main__':
    do_deploy(QA, CAMPING_MART_LIST, RELEASE_VERSION, release_file)
