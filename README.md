# About

This repository is initially a fork of [nuxeo-helm-chart](https://github.com/nuxeo/nuxeo-helm-chart) with the aim to provide a simple way to deploy Nuxeo in multi-tenants on a GKE/K8S cluster.

Progressively, this repository evolved to be become a simple 'overlay' of the default Helm Chart from [nuxeo-helm-chart](https://github.com/nuxeo/nuxeo-helm-chart) in order to just contain the needed configuration and additional resources.

Typically, the goals are:

 - provide a multi-tenant deployment of Nuxeo
 - support multiple types of Nuxeo architecture
 - manage autoscaling
 - manage monitoring
 - deploy additional services like Nuxeo Advanced Viewer

## What does the repository provide?

Compared to the default Helm Chart, this repository provides several additions:

 - deploy the shared storage layer with a configuration *closer* to production
    - HA setup + persistence (PVC and StatefulSet) 
    - see values files in the [storage](storage) directory
    - see the `deploy-storage.sh` script
 - provide sample configuration for multiple tenants
    - shared configuration
    - per-tenant configuration
    - see values files in the [tenants](tenants) directory
    - see the `deploy-tenantX.sh` scripts
 - deploy monitoring and a grafana dashboard
    - see the [monitoring](monitoring) folder and associated [ReadMe](monitoring/ReadMe.md)
 - configure pod autoscaling
    - see [hpa](hpa) folder and associated [ReadMe](hpa/ReadMe.md)
 - configure TLS encryption using letsencryt or static wildcard certificates
    - see [tls-ingress](tls-ingress) folder and and associated [ReadMe](tls-ingress/ReadMe.md)
 - deploy Nuxeo Enhanced Viewer in multi-tenants mode
    - see [nev](nev) folder and associated [ReadMe](nev/ReadMe.md)

The diagram below provides a logical overview of the deployed 
![Multitenant K8S deployment overview](img/k8s-mt-overview.png)

## Docker image and Nuxeo plugins

To make testing easier, we use the image built by the code in [nuxeo-tenant-test-image](https://github.com/tiry/nuxeo-tenant-test-image).

The provided Package contains:

 - a [dummy plugin](https://github.com/tiry/nuxeo-tenant-test-image/tree/master/plugins/plugin-core) to visually identify tenants from the login screen
 - [custom metrics reporter](https://github.com/tiry/nuxeo-tenant-test-image/tree/master/plugins/k8s-hpa-metrics) that tags the metric to emnable usage by HPA
 - [http session extender](https://github.com/tiry/nuxeo-tenant-test-image/tree/master/plugins/nuxeo-extended-session) to allow to scale out/down without being disconnected
 
In addition, the target image includes:

 - google-storage
 - nuxeo-web-ui
 - [nuxeo-statistics](https://github.com/nuxeo-sandbox/nuxeo-statistics)
 - optionnally nuxeo-arender

The 2 resulting images (w or w/o NEV) are then pushed to GCR that feeds the GKE deployment.

Versions used in these tests :

 - Nuxeo 11.4.42
 - google-storage-11.4.42.zip
 - nuxeo-web-ui-3.1.0-rc.9.zip
 - nuxeo-arender-11.0.0-RC1.zip

NB: need to align on LTS when available

# K8S Setup 

## Helm 3

Helm3 needs to be available in your (client environment).

## Install ingress controler Nginx

You need to deploy an ingress controller in your K8S cluster.
We use nginx in order to be as platform agnostic as possible.

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

	kubectl wait --namespace ingress-nginx \
	  --for=condition=ready pod \
	  --selector=app.kubernetes.io/component=controller \
	  --timeout=90s

# Deploy the Nuxeo Cluster

## Principles used to deploy multiple nuxeo applications

### Shared storage

The shared storage services (mongodb, elasticsearch, kafka, redis ...) are deployed in a dedicated namespace (for example `nx-shared-storage` namespace).

Each new tenant is composed of:

 - Nuxeo pods running in a dedicated *"tenant"* namespace 
 - a new storage space allocated inside the shared storage layer
    - `<tenant>` database in MongoDB
    - `<tenant>-` prefix for Elasticsearch indexes
    - `<tenant>-` prefix for Kafka topic

The assumtion is that the Shared Storage is deployed first and then the Nuxeo tenants are deployed.

### Tenant deployment

Each tenant is the deployment of a new namespace containing Nuxeo pods.

The Nuxeo pods are running a custom Nuxeo image that contains the tenant specific set of packages and configuration. Here, in the provided examples, all tenants run basically the same image and simply have a different `tenantId` but nothing prevent to change the deployed image in the `tennants/*-values.yaml`.

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

This shell script is simply executing `helm install` on the helm chart for the various storage service providers.

    ...
    helm3 upgrade -i  nuxeo-es  elasticsearch --repo https://helm.elastic.co  --version 7.9.2 -n   nx-shared-storage  --create-namespace  -f storage/es-values.yaml 
    ...

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

## Sample deployments

5 configurations are provided for testing purpose:

**Tenant 1**

 - description: standard deployment with 2 types of Nuxeo nodes (Api and Worker nodes)
 - namespace: api-worker
 - DNS: company-a.multitenant.nuxeo.com

**Tenant 2**

 - description: minimal deployment with only one type of node
 - namespace: minimal
 - DNS: company-b.multitenant.nuxeo.com

**Tenant 3**

 - description: API/Worker deployment with HPA for Autoscaling
 - namespace: autoscale
 - DNS: company-c.multitenant.nuxeo.com
 
**Tenant 4**

 - description: API/Worker deployment with Nuxeo Extended Viewer
 - namespace: nuxeo-nev
 - DNS: company-d.multitenant.nuxeo.com 

**Tenant 5**

 - description: API/Worker deployment with usage metrics
 - namespace: dashboard
 - DNS: company-e.multitenant.nuxeo.com 

## Testing the cluster

### https access

There are 5 deployed nuxeo:

 - https://company-a.multitenant.nuxeo.com/nuxeo
 - https://company-b.multitenant.nuxeo.com/nuxeo
 - ...
 - https://company-e.multitenant.nuxeo.com/nuxeo

When deployed, Grafana will be availble on: https://grafana.multitenant.nuxeo.com/

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

    kafka-topics.sh --list --zookeeper nuxeo-kafka-zookeeper

Cleanup Kafka topics for a given tenant:

    kubectl exec -ti nuxeo-kafka-0 -n nx-shared-storage  -- kafka-topics.sh --delete --zookeeper nuxeo-kafka-zookeeper --topic nuxeo-company-e.*

### Scale

Scaling can nbe controlled manually:

    kubectl scale deployment.v1.apps/nuxeo-cluster-nuxeo-app1 --replicas=2

See [hpa](hpa/ReadMe.md) for more details.

## Open questions

### Shell + Helm3 or Helmfile

The current deployment uses multiple Helm3 templates and try to coordinate them using some shell scripts.

There are several limitations with this approach:

 - need to use `envsubst` to pre-process some `values.yaml` files
 - some variables need to be shared between multiple helm templates

Using [helmfile](https://github.com/roboll/helmfile) seems to be the way to fix this.

### Operation logic

The current approach is to rely on existing K8S resources:

 - deploy helm charts representing the various part of a Nuxeo Deployment
 - deploy metrics and HPA for auto-scaling


