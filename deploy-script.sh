#/bin/bash

echo "Deploy " $1

# we want to install the chart and use 3 levels of values
# - 0: the values.yaml that is part of the default nuxeo chart
# - 1: the nuxeo-shared-values.yaml that is common to all the tenants
# - 2: the tenantXXX-values.yaml that contains the tenant specific values
#
# The resulting call would be something like:
# helm3 upgrade -i nuxeo \
#     -n tenantXXX --create-namespace \
#	 -f tenants/nuxeo-shared-values.yaml \
#	 -f tenants/tenantXXX-values.yaml 
#
# However, Helm3 does not do merge between the 2 values files passed using -f
# this means that the tenantXXX-values.yaml will completely overwrite 
# any existing entry in the nuxeo-shared-values.yaml
# (Here it will break the ingress configuration)
#
# the workaround is to do the merge by hand using the yq cli
#
# https://github.com/mikefarah/yq

yq m tenants/nuxeo-shared-values.yaml tenants/$1-values.yaml > $1-generated-values.yaml

helm3 upgrade -i nuxeo \
     -n $1 --create-namespace \
	 -f $1-generated-values.yaml \
	 --set clid=${NXCLID} \
     --set gcpb64=${NXGCPB64} \
	  nuxeo

rm $1-generated-values.yaml