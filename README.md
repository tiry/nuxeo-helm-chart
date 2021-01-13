# About

This repository is initially a fork of [nuxeo-helm-chart](https://github.com/nuxeo/nuxeo-helm-chart) with the aim to provide a simple way to deploy Nuxeo in multi-tenants on a GKE/K8S cluster.

Progressively, this repository evolved to be become a simple'overlay' of the default Helm Chart from [nuxeo-helm-chart](https://github.com/nuxeo/nuxeo-helm-chart) in order to just contain the needed configuration and additional resources.

## Additions

Compared to the default Helm Chart, this repository provides several adjustemnts:

 - deploy the shared storage layer with a configuration closer to production
    - HA + persistence 
    - see values files in the [storage](storage) directory
 - provide sample configuration for multiple tenants
    - shared configuration
    - per-tenant configuration
    - see values files in the [tenants](tenants) directory
 - deploy monitoring and a grafana dashboard
    - see [monitoring](monitoring)
 - configure pod autoscaling
    - see [hpa](hpa)
 - configure TLS encryption using letsencryt
    - see [tls](tls)
 - deploy Nuxeo Enhancer Viewer in multi-tenants mode
    - see [nev](nev) (WIP)

## Docker image and Nuxeo plugins

To make testing easier, we use the image built by the code in [nuxeo-tenant-test-image](https://github.com/tiry/nuxeo-tenant-test-image):

 - provide a simple way to identify tenants visually by configuring login screen
 - custom K8S metrics for HPA
 - http session extender to allow to scale out/down without being disconnected
 - build and publish in GCR a ready to deploy image (w or w/o NEV)

# K8S Setup 

## Helm 3

Helm3 needs to be available in your environment.

## Install ingress controler Nginx

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

	kubectl wait --namespace ingress-nginx \
	  --for=condition=ready pod \
	  --selector=app.kubernetes.io/component=controller \
	  --timeout=90s

# Deploy nuxeo Cluster

## Principles used to deploy multiple nuxeo application

### Shared storage

The shared storage services (mongodb, elasticsearch, kafka, redis ...) are deployed in a dedicated namespace (for example `nx-shared-storage` namespace).

Each new tenant is composed of:

 - Nuxeo pods running in a dedicated *"tenant"* namespace 
 - a new storage space allocated inside the shared storage layer
    - `<tenant>` database in MongoDB
    - `<tenant>-` prefix for Elasticsearch indexes
    - `<tenant>-` prefix for Kafka topic

### Tenant deployment

Each tenant is the deployment of a new namespace containing Nuxeo pods.

The Nuxeo pods are running a custom Nuxeo image that contains the tenant specific set of packages and configuration.

Currently, the service account used by the Nuxeo tenant to access the Storage Services is expected to have the rights to creaate DB, and indexes.

When generating the deployment template for a trenant, the values will be take from:

 - the default `values.yaml`
 - the `nuxeo-shared-values.yaml` for the configuration shared between tenants of the same cluster
 - the `<tenantId>-values.yaml` for the configuration specific to a tenant
 
### Ingress

For each tenant, we deploy (in the same namespace) an ingress that will accept request for hostname `<tenantId>.domain.com`. 

## Deploy 

### Deploy Storage layer

Use the provided shell script:

    ./deploy-storage.sh

This shell script is simply executing `helm install` on the helm chart for the storage service providers.

    helm3 upgrade -i  nuxeo-es  elasticsearch --repo https://helm.elastic.co  --version 7.9.2 -n   nx-shared-storage  --create-namespace  -f storage/es-values.yaml 

Because we use Helm3, we can set the target namespace.

The deploy-storage.sh supports 2 variant:

    ./deploy-storage.sh

Will deploy a "dev" minimal storage layer.

    ./deploy-storage.sh PROD

Will deploy a more production grade storage layer:

 - Elasticsearch
    - 3 master nodes
    - 3 data nodes
 - MongoDB
    - 2 repocaset nodes
    - 1 arbitrer node
 - Kafka
    - 3 brokers
    - 3 zookeepers

### Deploy a tenant

Use the provided shell script:

    ./deploy-tenant1.sh

We are simply calling Helm install in a dedciated namespace:

    helm3 upgrade -i nuxeo \
     -n tenant1 --create-namespace \
	 -f tenants/nuxeo-shared-values.yaml \
	 -f tenants/tenant1-values.yaml \
	 --debug \
	 --set clid=${NXCLID} \
     --set gcpb64=${NXGCPB64} \
	  nuxeo

The tenant specific configuration is located in tenants/tenant1-values.yaml

    nameOverride: company-a
    architecture: api-worker
    ingress.hostname: company-a.nxmt

The architecture choice is currently between:

 - singleNode: only one type of Nuxeo node is deployed
 - api-worker: deploys 2 types of pods
    - api nodes : exposed via the ingress but not processing any async work
    - worker nodes: not exposed via the ingress and dedicated to async processing

## Testing the cluster

### http access

There are 2 deployed nuxeo:

 - company-a.nxmt/nuxeo
 - company-b.nxmt/nuxeo
 
### Checking ES indices

Enter one of the Nuxeo containers for tenant1

    kubectl get pods -n tenant1

Sample output:

    NAME                              READY   STATUS    RESTARTS   AGE
    nuxeo-company-a-874b8b574-gnc7z   1/1     Running   0          41m
    nuxeo-company-a-874b8b574-vr89t   1/1     Running   0          41m

Enter one of the Nuxeo pod

    kubectl exec -n tenant1 -ti nuxeo-company-a-874b8b574-gnc7z -- /bin/bash

Then from within the shell in Nuxeo:

	wget -O  - http://elasticsearch-master.nx-shared-storage.svc.cluster.local:9200/_cat/indices
    
### Checking Mongo Databases

    get pods -n nx-shared-storage | grep mongodb

	kubectl exec -ti -n nx-shared-storage nuxeo-mongodb-5865fd69c8-xbfx4 -- /bin/bash

Start Mongo CLI

    mongo -u root -p XXX

Listing databases

    db.adminCommand( { listDatabases: 1 } )

Listing collections

    use company-a
    db.runCommand( { listCollections: 1, nameOnly: true } )

### Checking Kafka

    kubectl get pods -n nx-shared-storage | grep kafka

    kubectl exec -ti nuxeo-kafka-0 -n nx-shared-storage  -- /bin/bash

List Kafka topics:

    kafka-topics --list --zookeeper nuxeo-kafka-zookeeper

### Scale

kubectl scale deployment.v1.apps/nuxeo-cluster-nuxeo-app1 --replicas=2



