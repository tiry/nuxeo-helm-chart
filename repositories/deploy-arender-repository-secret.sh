#/bin/bash

tenant=$1

echo "Deploy Namespace $tenant (if needed)"

echo -e "apiVersion: v1\nkind: Namespace\nmetadata:\n  name: ${tenant}" | kubectl apply -f - 

echo "Generate secret"

kubectl -n $tenant create secret docker-registry arender-repo \
 --docker-server=docker-arender.packages.nuxeo.com/ \
 --docker-username=$NEXUS_TOKEN_NAME \
 --docker-password=$NEXUS_TOKEN_PASS
 