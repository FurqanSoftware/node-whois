# Syncs servers.json with iana.org

import json
import re
import requests

servers = json.loads(open('servers.json').read())

for tld in servers.keys():
  try:
    if servers[tld]:
      # already known, skip tld
      print(str(tld) + ': - ' + servers[tld])
      continue

    text = requests.get('http://www.iana.org/whois?q=' + tld).text
    matches = re.findall('(?:refer|whois):\s*(.+)', text)
    
    if matches:
      servers[tld] = matches[0]
      print(str(tld) + ': ' + matches[0])
    else:
      print(str(tld) + ': ?')
  
  except:
    print('!')

open('servers.json', 'w+').write(json.dumps(servers, indent=2))