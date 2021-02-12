#/bin/bash

echo "deployment with api and worker nodes for Nuxeo"

./repositories/deploy-nuxeo-repository-secret.sh final1

./deploy-script.sh final1

