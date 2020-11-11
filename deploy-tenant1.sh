#/bin/bash

echo "Deploy tenant1"

#kubectl create namespace company-a
helm3 upgrade -i nuxeo \
	 -f nuxeo/tenant1-values.yaml \
	 --debug \
	 --set nuxeo.clid=${NXCLID} \
	  nuxeo
