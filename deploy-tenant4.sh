#/bin/bash

echo "Deploy Nuxeo with Extended Viewer"

./deploy-script.sh nuxeo-nev

echo "Deploy NEV"

cd nev

./deploy-preview.sh nuxeo-nev

cd ..


