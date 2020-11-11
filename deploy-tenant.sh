#/bin/bash

echo "Deploy tenant1"
helm3 upgrade -i nuxeo \
	 -f nuxeo/tenant1-values.yaml \
	 --debug \
	 --dry-run \
	 --set nuxeo.clid=${NXCLID} \
	  nuxeo

