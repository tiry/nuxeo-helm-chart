#/bin/bash

../repositories/deploy-arender-repository-secret.sh nev-shared

helm3 upgrade -i arender arender \
     --repo https://packages.nuxeo.com/repository/helm-releases/  \
     --version  0.2.3 \
     -n nev-shared --create-namespace \
	 -f nev-common-values.yaml \
	 -f nev-shared-values.yaml \
     --password $NEXUS_TOKEN_PASS \
     --username $NEXUS_TOKEN_NAME 
