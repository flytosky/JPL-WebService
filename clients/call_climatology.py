import httplib2, urllib
try:
    import simplejson as json
except Exception, e:
    import json
from urllib import urlencode
from urllib2 import HTTPError

model = 'ukmo'
data = '/static/'
image = '/static/'
parameters = {'model':radius}
urlparams = urlencode(parameters)
print 'urlparams: ', urlparams
url = 'http://lpanl.homeip.net:8888/' + 'invest/area?' + urlparams
print 'url: ', url
headers = {"Content-type": "multipart/form-data"}
try:
  http = httplib2.Http('.cache')
  (response, content) = http.request(url, 'GET', '', headers)
  ### print type(content)
  ### print 'len: ', len(content)
  ### print 'content: ', content

  obj = json.loads(content)
  print obj

  area = obj['area']
  print 'area: ', area
except httplib2.HttpLib2Error, e:
  # the Base Exception for all exceptions raised by httplib2.
  msg = 'Unable to call "%s" due to %s: %s' % (url, type(e), str(e))
  print msg
except Exception, e:
  # any other exceptions
  msg = 'Unable to call "%s" due to %s: %s' % (url, type(e), str(e))
  print msg
# end try-except
