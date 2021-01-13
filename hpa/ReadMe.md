## Principles

The standard Nuxeo deployment contains 2 types of nodes:

 - api nodes: handling synchronous workload
 - worker nodes : handling asynchronous workload

In K8S, these 2 types of nodes are deployed via 2 dedicated deployments using the same Docker image and with just a few minor configuration differences.

The goal is to scale the 2 deployments up/down depending on the load.

Typically:

 - api nodes should be scaled out when too much synchronous load is applied
    - typically too much CPU or memory pressure
 - worker nodes should be scaled out when the lag is too big
    - size of the queues and lags of stream processors

## Metrics 

### Generic Nuxeo Metrics

Nuxeo uses Coda Hale Yammer Metrics to expose nuxeo specific metrics.

See: https://doc.nuxeo.com/nxdoc/metrics-and-monitoring/

Nuxeo exposes a lot of metrics (JVM, Tomcat, Repository, Stream processing, Work Manager ...) and then you need to configure how to access and view the metrics:

 - JMX access
 - export to DataDog
 - export to Graphana
 - export to StackDriver
 - ...

See: 

 - [default configuration template](https://github.com/nuxeo/nuxeo/blob/master/server/nuxeo-nxr-server/src/main/resources/templates/common-base/nxserver/config/metrics-config.xml)
 - [available reporters](https://github.com/nuxeo/nuxeo/tree/master/modules/runtime/nuxeo-runtime-metrics/src/main/java/org/nuxeo/runtime/metrics/reporter)

### StackDriver for GCP/GKE and specificities for the K8S HPA

For the K8S pod autoscaler to work, the resources exposed need to be tagged with the correct resource type otherwise the HPA will complain that the metric can be be read.

In GKE, we use `StackDriver` and the default resource type is set to `k8s_container` whereas it needs to be `k8s_pod` for the HPA.

In order to work around that, the deployed image include the [k8s-hpa-metrics](https://github.com/tiry/nuxeo-tenant-test-image/tree/master/plugins/k8s-hpa-metrics) addon that:

 - properly tag resources and metrics
 - exposes an additional metrics dedicated to asynchronouys workload

Because of the first point, the helm values is set with:

    ...
    metrics:
        enabled: true
        stackdriver:
            enabled: false
    ...
  
It means that we disable the default stackdriver reporter and rely on the fact thet the [k8s-hpa-metrics specific reporter](https://github.com/tiry/nuxeo-tenant-test-image/blob/master/plugins/k8s-hpa-metrics/src/main/resources/OSGI-INF/metrics-config.xml) is activated.

For the second point, the addon expose an aggregated metrics called `nuxeo.async.load` that is based on 

## Deploying HPA

## Testing Autoscaling

### API Nodes

#### Generating load to validate Scale out

In this example, we will generate load on `company-c` that is hosted in `tenant3`

    ./inject_cpu_load.sh company-c

#### Checking deployment autoscaling

You can check the Events in the corresponding deployment

    kubectl describe deployment nuxeo-company-c-api -n tenant3


    Name:                   nuxeo-company-c-api
    Namespace:              tenant3
    ...
    Events:
        Type    Reason             Age   From                   Message
        ----    ------             ----  ----                   -------
        Normal  ScalingReplicaSet  60m   deployment-controller  Scaled up replica set nuxeo-company-c-api-69978c67f8 to 1
        Normal  ScalingReplicaSet  7m4s  deployment-controller  Scaled up replica set nuxeo-company-c-api-69978c67f8 to 3
        Normal  ScalingReplicaSet  4s    deployment-controller  Scaled down replica set nuxeo-company-c-api-69978c67f8 to 1

You can also check the HPA

    kubectl describe  hpa nuxeo-company-c-api   -n tenant3

    Name:                                                  nuxeo-company-c-api
    Namespace:                                             tenant3
    ...
    Min replicas:                                          1
    Max replicas:                                          5
    Deployment pods:                                       1 current / 1 desired
    Conditions:
    Type            Status  Reason              Message
    ----            ------  ------              -------
    AbleToScale     True    ReadyForNewScale    recommended size matches current size
    ScalingActive   True    ValidMetricFound    the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request)
    ScalingLimited  False   DesiredWithinRange  the desired count is within the acceptable range
    Events:
    Type    Reason             Age    From                       Message
    ----    ------             ----   ----                       -------
    Normal  SuccessfulRescale  7m37s  horizontal-pod-autoscaler  New size: 3; reason: cpu resource utilization (percentage of request) above target
    Normal  SuccessfulRescale  37s    horizontal-pod-autoscaler  New size: 1; reason: All metrics below target

### Worker nodes

#### Generating load to validate Scale out

In this example, we will generate async workload on `company-c` that is hosted in `tenant3`

    ./inject_worker_load.sh company-c

#### Checking deployment autoscaling

You can check the Events in the corresponding hpa

    kubectl describe hpa nuxeo-company-c-worker -n tenant3
    
    Name:                                                          nuxeo-company-c-worker
    Namespace:                                                                   tenant3
    ...
    Events:
    Type    Reason             Age   From                       Message
    ----    ------             ----  ----                       -------
    Normal  SuccessfulRescale  27m   horizontal-pod-autoscaler  New size: 2; reason: pods metric custom.googleapis.com|nuxeo|dropwizard5_nuxeo.async.load_gauge above target
    Normal  SuccessfulRescale  18m   horizontal-pod-autoscaler  New size: 3; reason: pods metric custom.googleapis.com|nuxeo|dropwizard5_nuxeo.async.load_gauge above target
    Normal  SuccessfulRescale  8m7s  horizontal-pod-autoscaler  New size: 1; reason: All metrics below target

