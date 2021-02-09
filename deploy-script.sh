#/bin/bash

T=$1

echo "Deploy tenant $T"

kubectl create namespace $T


./tls-ingress/deploy-tls-if-needed.sh $T

#echo "Deploy letsencrypt Certificate Issuers"
#kubectl create -n $T -f tls-ingress/letsencrypt-prod-issuer.yaml
#kubectl create -n $T -f tls-ingress/letsencrypt-staging-issuer.yaml

#echo "Deploy wildcard static certificate"
#./tls-ingress/create-tls-secret-from-pem.sh $T


echo "Deploy Nuxeo Cluster:"

# preprocess values.yaml to replace some env variables

envsubst < tenants/$T-values.yaml > tmp-$T-values.yaml

envsubst < tenants/nuxeo-shared-values.yaml > $T-nuxeo-shared-values.yaml

helm3 upgrade -i nuxeo nuxeo \
     --repo https://chartmuseum.platform.dev.nuxeo.com/  \
     --version  2.0.2 \
     -n $T --create-namespace \
	 -f $T-nuxeo-shared-values.yaml \
	 -f tmp-$T-values.yaml \
	 --set clid=${NXCLID}

# do some cleanup
rm tmp-$T-values.yaml
rm $T-nuxeo-shared-values.yaml

