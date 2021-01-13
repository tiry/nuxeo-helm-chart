#/bin/bash

echo "Deploy Grafana Ingress"

kubectl create -n nx-monitoring -f ingress.yaml
