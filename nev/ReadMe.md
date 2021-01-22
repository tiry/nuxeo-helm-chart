### About Nuxeo Enhanced Viewer

This module provides tools to deploy Nuxeo Emhanced Viewer in a K8S cluster.

The idea is that inside the K8S cluster:

 - multiple Nuxeo clusters can be deployed: each Nuxeo cluster is in a dedicated namespace
 - a shared storage namespace provides the services needs for persistence

For NEV, the idea is to use a similar model:

 - deploy the ARender "rendition" services in a shared namespace
    - i.e. here the default namespace is `nev-shared`
 - for each tenant/nuxeo cluster, a new arender-previewer pod is deployed in the target namespace

### Deploying

#### Secrets

Both deployment scripts (deploy-preview.sh and deploy-shared-infrastructure.sh) include the deployment of the needed secrets to be able to fetch the containers via the script:

    ./init-secret.sh $tenant

For that the current script expect 2 environment variables:

    NEXUS_TOKEN_NAME: login to fetch the Docker images
    NEXUS_TOKEN_PASS: password to fetch the Docker images

#### Deploy shared services

Deploy ARender shared services (target namespace will be `nev-shared` )

    nev/deploy-shared-services.sh

#### Deploy tenant specific previewer

Deploy ARender previewer in tenant/namespace "tenant4"

    nev/deploy-preview.sh tenant4    

On the Nuxeo side, you need to use an image that container the ARender addon and deploy custom configuration properties (see `tenant4-values.yaml` for an example)

    arender: |
      arender.server.previewer.host=https://arender-company-d.multitenant.nuxeo.com
      nuxeo.arender.oauth2.client.create=true
      nuxeo.arender.oauth2.client.id=arender
      nuxeo.arender.oauth2.client.secret=OAUTH2_SECRET
      nuxeo.arender.oauth2.client.redirectURI=/login/oauth2/code/nuxeo

NB: Nuxeo and NEV need to be deployed using TLS since we are using secured cookies. See `tls-ingress` sub folder.

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



