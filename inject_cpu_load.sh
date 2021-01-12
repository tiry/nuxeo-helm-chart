#/bin/bash

seq 1 5 | xargs -n1 -P 5 
curl -H 'Content-Type:application/json+nxrequest' \
-X POST -d '{"params":{"duration":"120"},"context":{}}' \
-u Administrator:Administrator \
https://company-a.multitenant.nuxeo.com/nuxeo/api/v1/automation/CPUWorkload.Simulate

