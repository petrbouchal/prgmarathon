
# coding: utf-8

# In[7]:

import requests
import json

subeventid = [11875]

maraurl_base = "http://www.runczech.com/"
maraurl_path = "srv/www/api/runner-results/v1/results/"

totalrecs = requests.get(url=maraurl_base+maraurl_path,
                        data = {"per_page":100, "subeventid":subeventid, "page":1})

totalrecords=json.loads(totalrecs.content)['totalNumberOfRecords']
totalrecords


# In[9]:

pagenumbers = range(1,((totalrecords // 100 + 2)))

for i in pagenumbers[1:3]:
    records = requests.get(url=maraurl_base+maraurl_path,
                           data = {"per_page":100, "subeventid":subeventid, "page":i})
    # print(records.json())
    print(json.loads(records.content)['data'][1]['runnerId'])
    print(records.content)


# In[ ]:




# In[ ]:




# In[ ]:




# In[ ]:




# In[ ]:




# In[ ]:




# In[ ]:
