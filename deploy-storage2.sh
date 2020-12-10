#/bin/bash

NS="nx-shared-storage2"

echo "Deploy Elasticsearch"
#helm3 upgrade -i  nuxeo-es-master  elasticsearch \
#  --repo https://helm.elastic.co  \
#  --version 7.9.2 -n $NS \
#  --create-namespace  -f storage/es-values.yaml -f storage/es-values-master.yaml 

#helm3 upgrade -i  nuxeo-es-data  elasticsearch \
#  --repo https://helm.elastic.co  \
#  --version 7.9.2 -n $NS \
#  --create-namespace  -f storage/es-values.yaml -f storage/es-values-data.yaml 

echo "Deploy MongoDB"
helm3 upgrade -i  nuxeo-mongodb  mongodb \
  --debug \
  --repo https://charts.bitnami.com/bitnami  \
  --version 10.1.1 -n $NS \
  --set mongodb.architecture="replicaset" \
  --create-namespace -f storage/mongodb-values.yaml 

#https://charts.bitnami.com/bitnami/mongodb-10.1.1.tgz
#https://charts.bitnami.com/bitnami/helm/mongodb/mongodb-7.14.2.tgz

echo "Deploy Kafka"
#helm3 upgrade -i  nuxeo-kafka  kafka \
#  --repo http://storage.googleapis.com/kubernetes-charts-incubator  \
#  --version ~0.20.8 -n $NS \
#  --create-namespace  -f storage/kafka-values.yaml 

