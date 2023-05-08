+++
title = "API"
date = 2023-03-23
section = "marginalia-search"
aliases = ["/projects/edge/api.gmi"]
draft = false
categories = ["docs", "outdated"]
+++

An API for the search engine is available through api.marginalia.nu. 

The API is simple enough to be self-explanatory. Examples:

```
https://api.marginalia.nu/public/
https://api.marginalia.nu/public/search/json+api
https://api.marginalia.nu/public/search/json+api?index=0
https://api.marginalia.nu/public/search/json+api?index=0&count=10
```

The 'index' parameter selects the search index, corresponding to the drop down next to the search field in the main GUI. 

## Common Key
For experimentation, the key "public" is available, as used in the examples on this page. This key has a shared rate limit across all consumers. When this rate limit is hit a HTTP status 503 is returned. 

## Key and license

Please send an email to kontakt@marginalia.nu if you want your own key with a separate rate limit. The search engine has seen quite a lot of problems with bot abuse, making this registration step a sad necessity. 

No guarantees can be made about uptime or availability.

By default the data is provided under the CC-BY-NC-SA 4.0 license. Other licensing and terms are negotiable.

* [CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)

## Sample code in python 3
```
import requests

url = "https://api.marginalia.nu/{key}/search/{query}";

rsp = requests.get(url.format(key='public', query="linear b"));

if rsp.ok:
  data = rsp.json()
  print ("Query: ", data['query'])
  print ("License: ", data['license'])
  print ("")
  for result in data['results']:
      print (result['url'])
      print ("\t" + result['title'])
      print ("\t" + result['description'])
      print ("")
else:
    print ("Bad Status " + str(rsp.status_code))
```

## Something missing?

Please let me know if there are features you would like added to the API.

## See also

* [Data sets from the search engine](https://downloads.marginalia.nu/)