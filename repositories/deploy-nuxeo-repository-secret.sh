#/bin/bash

tenant=$1

echo "Deploy Namespace $tenant (if needed)"

echo -e "apiVersion: v1\nkind: Namespace\nmetadata:\n  name: ${tenant}" | kubectl apply -f - 

echo "Generate secret"

kubectl -n $tenant delete secret nxprivate-repo --ignore-not-found

kubectl -n $tenant create secret docker-registry nxprivate-repo \
 --docker-server=docker-private.packages.nuxeo.com/ \
 --docker-username=$NEXUS_TOKEN_NAME \
 --docker-password=$NEXUS_TOKEN_PASS
 