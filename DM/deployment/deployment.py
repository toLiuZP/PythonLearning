import os
import sys
sys.path.append(os.getcwd())

import conf.acct as acct
from tool.tool import file_name,logger 
import db_connect.db_operator as db_operator

release_file = {
    'PK00':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\PK0000_Main.sql',
    'HF00':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\PKHF00_Main.sql',
    '1902':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\PK1902_Main.sql',
    '1903':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\PK1903_Main.sql',
    '1904':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\PK1904_Main.sql',
    '1905':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\PK1905_Main.sql',
    '190401':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\PK190401_Main.sql',
    '1906':r'D:\Work\02. SVN\Aspira\SQL\AWO_Data_Mart\trunk\Deployment\CAMPING_MART\PK1906_Main.sql',
}

DEV = acct.DEV_TX_CAMPING_MART
QA = acct.QA_TX_CAMPING_MART

# FULL_CAMPING_MART_LIST = ['CO_CAMPING_MART','DE_CAMPING_MART','GA_CAMPING_MART','IA_CAMPING_MART','KS_CAMPING_MART','MS_CAMPING_MART','NC_CAMPING_MART','NY_CAMPING_MART','OR_CAMPING_MART','PA_CAMPING_MART','TX_CAMPING_MART','UT_CAMPING_MART','VA_CAMPING_MART','VT_CAMPING_MART']
CAMPING_MART_LIST = ['OR_CAMPING_MART']

# create as initial 
# FULL_RELEASE_VERSION = ['HF00','1902','1903','1904','1904_01']

RELEASE_VERSION = ['PK00','1902','1903','1904','190401','1905','1906']

@logger
def do_deploy(acct:dict, CAMPING_MART_LIST, RELEASE_VERSION, release_file):

    release_scripts = build_release_scripts(RELEASE_VERSION, release_file)

    for client in CAMPING_MART_LIST:
        client_scripts = release_scripts
        client_scripts = client_scripts.replace('{TARGET_CAMPING_MART}',client).replace('GO\n','\n')

        restfilename = r'.\deployment\release_scripts\\' + client + '.sql'
        with open(restfilename, 'w') as file_object:
            file_object.write(client_scripts)

        #db_operator.update_db(client_scripts,acct)

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
