#/bin/bash


seq 1 5 | xargs -n1 -P 5 
curl -k -H 'Content-Type:application/json+nxrequest' \
-X POST -d '{"params":{"duration":"120"},"context":{}}' \
-u Administrator:Administrator \
https://$1.multitenant.nuxeo.com/nuxeo/api/v1/automation/CPUWorkload.Simulate


