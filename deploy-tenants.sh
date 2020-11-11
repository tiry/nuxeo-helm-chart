#/bin/bash

echo "Deploy tenant1"

kubectl create namespace company-a
helm3 upgrade -i nuxeo-t1 \
	 -f nuxeo/tenant1-values.yaml \
	 --debug \
	 --set nuxeo.clid=${NXCLID} \
	  nuxeo

echo "Deploy tenant2"

kubectl create namespace company-b
helm3 upgrade -i nuxeo-t2 \
	 -f nuxeo/tenant2-values.yaml \
	 --debug \
	 --set nuxeo.clid=${NXCLID} \
	  nuxeo
