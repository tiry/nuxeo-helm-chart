#/bin/bash

echo "Deploy tenant1"

helm3 upgrade -i nuxeo \
     -n tenant1 --create-namespace \
	 -f nuxeo/nuxeo-shared-values.yaml \
	 -f nuxeo/tenant1-values.yaml \
	 --debug \
	 --set nuxeo.clid=${NXCLID} \
	  nuxeo

echo "Deploy tenant2"

helm3 upgrade -i nuxeo \
     -n tenant2 --create-namespace \
	 -f nuxeo/nuxeo-shared-values.yaml \
	 -f nuxeo/tenant2-values.yaml \
	 --debug \
	 --set nuxeo.clid=${NXCLID} \
	  nuxeo
