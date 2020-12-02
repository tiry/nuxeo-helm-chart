#/bin/bash

echo "Deploy Elasticsearch"
helm3 upgrade -i  nuxeo-es  elasticsearch --repo https://helm.elastic.co  --version 7.9.2 -n   nx-shared-storage  --create-namespace  -f storage/es-values.yaml 

echo "Deploy MongoDB"
helm3 upgrade -i  nuxeo-mongodb  mongodb --repo https://charts.bitnami.com/bitnami  --version ~7.14.2 -n nx-shared-storage --create-namespace  -f storage/mongodb-values.yaml 

echo "Deploy Kafka"
helm3 upgrade -i  nuxeo-kafka  kafka --repo http://storage.googleapis.com/kubernetes-charts-incubator  --version ~0.20.8 -n nx-shared-storage --create-namespace  -f storage/kafka-values.yaml 

