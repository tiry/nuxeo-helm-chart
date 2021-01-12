#/bin/bash

curl -H 'Content-Type:application/json+nxrequest' \
-X POST -d '{"params":{"nbWork":"30","duration":"30"},"context":{}}' \
-u Administrator:Administrator \
https://company-a.multitenant.nuxeo.com/nuxeo/api/v1/automation/Workload.Simulate

sleep 300

curl -H 'Content-Type:application/json+nxrequest' \
-X POST -d '{"params":{"nbWork":"20","duration":"50"},"context":{}}' \
-u Administrator:Administrator \
https://company-c.multitenant.nuxeo.com/nuxeo/api/v1/automation/Workload.Simulate

