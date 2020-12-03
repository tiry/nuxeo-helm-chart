#/bin/bash

echo "Deploy " $1

helm3 upgrade -i nuxeo \
	 --dry-run \
     -n $1 --create-namespace \
	 -f tenants/nuxeo-shared-values.yaml \
	 -f tenants/$1-values.yaml \
	 --set clid=${NXCLID} \
     --set gcpb64=${NXGCPB64} \
	  nuxeo
