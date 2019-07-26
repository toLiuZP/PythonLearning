import json


'''
f=open(r".\seed\business_key.json",'r')
print(json.load(f))
f.close()


t=file(r'.\seed\business_key.json')
test = json.load(f)
'''

filename = r'.\seed\business_key.json'
with open(filename) as f:
    t = json.load(f)

    for i in t:
        pass
    pass