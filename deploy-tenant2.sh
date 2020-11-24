#/bin/bash

echo "Deploy tenant1"

helm3 upgrade -i nuxeo \
     -n tenant2 --create-namespace \
	 -f nuxeo/nuxeo-shared-values.yaml \
	 -f nuxeo/tenant2-values.yaml \
	 --debug \
	 --set clid=${NXCLID} \
     --set gcpb64=${NXGCPB64} \
	  nuxeo
