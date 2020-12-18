#/bin/bash

if [ -n "$1" ];then

tenant=$1

echo "Add previewer to tenant $tenant"

./init-secret.sh $tenant

helm3 upgrade -i arender arender \
     --repo https://packages.nuxeo.com/repository/helm-releases/  \
     --version  0.2.3 \
     -n $tenant --create-namespace \
	 -f nev-common-values.yaml \
	 -f nev-previewer-values.yaml \
     --password $NEXUS_TOKEN_PASS \
     --username $NEXUS_TOKEN_NAME 

else 
  echo "please provide a tenant/namespace as first argument"
fi 