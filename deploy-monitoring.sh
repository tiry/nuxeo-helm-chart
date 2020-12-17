#/bin/bash

echo "Deploy Monitoring" 

# https://cloud.google.com/community/tutorials/visualizing-metrics-with-grafana

helm3 upgrade -i grafana grafana \
     --repo https://grafana.github.io/helm-charts \
	 --version 6.1.15 \
     -n nx-monitoring --create-namespace \
	 -f monitoring/values.yaml

	  
