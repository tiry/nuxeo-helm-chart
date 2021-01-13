#/bin/bash

curl -k -H 'Content-Type:application/json+nxrequest' \
-X POST -d '{"params":{"nbWork":"30","duration":"30"},"context":{}}' \
-u Administrator:Administrator \
https://$1.multitenant.nuxeo.com/nuxeo/api/v1/automation/Workload.Simulate
