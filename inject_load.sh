#/bin/bash

curl -H 'Content-Type:application/json+nxrequest' \
-X POST -d '{"params":{"nbWork":"30","duration":"30"},"context":{}}' \
-u Administrator:Administrator \
http://company-a.nxmt/nuxeo/api/v1/automation/Workload.Simulate

sleep 300

curl -H 'Content-Type:application/json+nxrequest' \
-X POST -d '{"params":{"nbWork":"20","duration":"50"},"context":{}}' \
-u Administrator:Administrator \
http://company-c.nxmt/nuxeo/api/v1/automation/Workload.Simulate
