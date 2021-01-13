#/bin/bash

TENANT=$1

echo "Deploy APINodes HPA for $TENANT"

TENANT=$TENANT envsubst < hpa-apinodes.yaml > tmp-$TENANT-hpa-apinodes.yaml
kubectl create -n $TENANT -f tmp-$TENANT-hpa-apinodes.yaml
rm tmp-$TENANT-hpa-apinodes.yaml

echo "Deploy WorkerNodes HPA for $TENANT"

TENANT=$TENANT envsubst < hpa-workernodes.yaml > tmp-$TENANT-hpa-workernodes.yaml
kubectl create -n $TENANT -f tmp-$TENANT-hpa-workernodes.yaml
rm tmp-$TENANT-hpa-workernodes.yaml

