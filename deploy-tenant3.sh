#/bin/bash

T="tenant3"

echo "Deploy $T"

# reprocess values.yaml to replace some env variables
envsubst < tenants/$T-values.yaml > tmp-$T-values.yaml

helm3 upgrade -i nuxeo nuxeo \
     --repo https://chartmuseum.platform.dev.nuxeo.com/  \
     --version  2.0-PR-30-3 \
     -n $T --create-namespace \
	 -f tenants/nuxeo-shared-values.yaml \
	 -f tmp-$T-values.yaml \
	 --set clid=${NXCLID}

# do some cleanup
rm tmp-$T-values.yaml