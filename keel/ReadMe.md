
## Why Keel

## Deploying

Deploy Keel on the K8S cluster

    kubectl create ns keel

    ../tls-ingress/deploy-tls-if-needed.sh keel

    kubectl create secret generic -n keel gcr-cred --from-file gcr-cred.json

    kubectl apply -f keel.yaml

## Access dashboard

    https://keel.multitenant.nuxeo.com/dashboard




