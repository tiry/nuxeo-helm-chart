### About Nuxeo Enhanced Viewer

This modules provides tools to deploy Nuxeo Emhanced Viewer in a K8S cluster.

The idea is that inside the K8S cluster:

 - multiple Nuxeo clusters can be deployed: each Nuxeo cluster is in a dedicated namespace
 - a shared storage namespace provides the services needs for persistence

For NEV, the target model is to:

 - deploy the ARender "rendition" services in a shared namespace
    - i.e. here the default namespace is `nev-shared`
 - for each tenant/nuxeo cluster, a new arender-previewer pod is deployed in the target namespace

### Deploying

This is a WIP!

Deploy ARender shared services (target namespace will be `nev-shared` )

    nev/deploy-shared-services.sh

Deploy ARender previewer in tenant/namespace "tenant4"

    nev/init-secret.sh tenant4
    nev/deploy-preview.sh tenant4    

### NEV resources

#### Nuxeo documentation

https://doc.nuxeo.com/nxdoc/nuxeo-enhanced-viewer/#arender-configuration

#### Arender documentation

https://arender.io/v4/documentation/install/kubernetes/

#### Docker images:

 - docker-arender.packages.nuxeo.com/nuxeo/arender-previewer:11.0.0-RC1
 - docker-arender.packages.nuxeo.com/arender-document-service-broker:4.0.9.NX1.0
 - docker-arender.packages.nuxeo.com/arender-document-converter:4.0.9.NX1.0
 - docker-arender.packages.nuxeo.com/arender-document-file-storage:4.0.9.NX1.0
 - docker-arender.packages.nuxeo.com/arender-document-renderer:4.0.9.NX1.0
 - docker-arender.packages.nuxeo.com/arender-document-text-handler:4.0.9.NX1.0

#### Nuxeo package

https://connect.nuxeo.com/nuxeo/site/marketplace/package/nuxeo-arender?version=11.0.0-RC1

#### Helm Chart

https://packages.nuxeo.com/repository/helm-releases/arender-0.2.3.tgz

Sample values: https://github.com/nuxeo/nuxeo-arender-connector/blob/master/ci/helm/nuxeo-arender/values_jx.yaml



