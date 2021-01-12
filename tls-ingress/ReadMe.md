
## Install Cert-Manager in K8S cluster

    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml

It should deploy CRDs and start 3 pods in the `cert-manager` namespace

    kubectl get pods --namespace cert-manager

## Create the issuers resources

Staging issuer (for testing)

    kubectl create -f letsencrypt-staging-issuer.yaml

Production issuer

    kubectl create -f letsencrypt-prod-issuer.yaml

Technically the issuer need to be created in each of the tenant namespace, typically:

    kubectl create -n tenant1 -f letsencrypt-prod-issuer.yaml

## Add the needed lines in the ingres definition

Add annotations in the ingres descriptor:

    metadata:
      annotations:
        kubernetes.io/ingress.class: "nginx"    
        cert-manager.io/issuer: "letsencrypt-prod"

Add the tls entry in the ingress descriptor:

    tls:
    - hosts:
      - company-a.multitenant.nuxeo.com
      secretName: company-a-tls

## Cert-Issuers and namespaces

The Cert-Issuer needs to be created either in the target "tenant" namespace or in the kube-system namespace.

## References: 

 https://cert-manager.io/docs/installation/kubernetes/

 https://cloud.google.com/kubernetes-engine/docs/concepts/ingress-xlb

 https://rancher.com/docs/rancher/v2.x/en/installation/resources/tls-secrets/

 https://stackoverflow.com/questions/51572249/why-does-google-cloud-show-an-error-when-using-clusterip

