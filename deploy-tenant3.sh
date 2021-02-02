#/bin/bash

echo "api/worker deployment with a autoscaling"

./deploy-script.sh autoscale

echo "deploy HPA"

cd hpa

./deploy-hpa.sh autoscale company-c

cd ..

# inject load


