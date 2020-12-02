#/bin/bash

echo "Deploy tenant1"

helm3 upgrade -i nuxeo \
     -n tenant1 --create-namespace \
	 -f tenants/nuxeo-shared-values.yaml \
	 -f tenants/tenant1-values.yaml \
	 --debug \
	 --set clid=${NXCLID} \
     --set gcpb64=${NXGCPB64} \
	  nuxeo

