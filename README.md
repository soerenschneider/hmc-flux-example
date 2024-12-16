# hmc-flux-example

Install hmc using flux2

## Repo structure
```
.
├── apps                        # catalogue of "apps" installable via flux
│   └── 2a
│       ├── aws
│       └── azure
├── infra                       # catalogue of infrastructure components installable via flux
│   ├── cert-manager
│   ├── flux-system
│   ├── hmc-system
│   └── sealed-secrets
├── management-clusters         # clusters managed by flux
│   └── kind              # local test cluster provided by "kind"
│       ├── hmc
│       └── infra
└── terraform                   # create users and access keys for cloud platforms, store as kubernetes secrets
    └── aws
```

### Kustomize manifests
Before checking out the kustomize manifests, [this FAQ entry](https://fluxcd.io/flux/faq/#are-there-two-kustomization-types) should be read first.

The example kind cluster defines two `kustomize.toolkit.fluxcd.io/v1` [manifests](management-clusters/kind/flux-kustomization.yaml), one to install infra components including CRDs and one to install everything else.

Define `kustomization.kustomize.config.k8s.io` manifests in the appropriate `management-clusters` to patch kustomize bases. An example that patches a `ManagedCluster` resource is found [here](management-clusters/kind/managed-clusters/aws-cluster-1/kustomization.yaml).

## Getting started

### Gain Access to a Kubernetes cluster

Either you use an already existing cluster or you can spin up a local management cluster using [kind](https://kind.sigs.k8s.io/).

In case of no existing cluster or as a local dev environment, you can use kind:
```
# Spin up testcluster using "kind"
$ kind create cluster
```

### Install initial flux manifests

```
# CRDs of flux are not available in the first run, therefore we apply it twice
$ kubectl apply -k management-clusters/kind; kubectl apply -k management-clusters/kind

# Give flux some time and the status of the kustomization
$ k get kustomizations.kustomize.toolkit.fluxcd.io -A
NAMESPACE     NAME           AGE    READY   STATUS
flux-system   clusters-aws   12m    True    Applied revision: main@sha1:9b569c93bb5cd410eb8ca2999aabb0868091a629
flux-system   credentials    12m    True    Applied revision: main@sha1:9b569c93bb5cd410eb8ca2999aabb0868091a629
flux-system   infra          12m    True    Applied revision: main@sha1:9b569c93bb5cd410eb8ca2999aabb0868091a629
```

### Create AWS resources

IAM credentials are needed to provision resources using CAPA. 

This repo contains [terraform code and instructions](terraform/aws/README.md) that creates a user, IAM credentials and a Kubernetes secret that allow creating AWS resources.

### Verifying HMC status
After some time has passed, the state of the cluster should look like this:

```
$ kubectl get pods -A
NAMESPACE            NAME                                                          READY   STATUS      RESTARTS        AGE
flux-system          helm-controller-7f788c795c-6dqkh                              1/1     Running     0               8m45s
flux-system          kustomize-controller-b4f45fff6-c4wk4                          1/1     Running     0               8m45s
flux-system          notification-controller-556b8867f8-wf7pb                      1/1     Running     0               8m45s
flux-system          source-controller-77d6cd56c9-stq7h                            1/1     Running     0               8m45s
hmc-system           azureserviceoperator-controller-manager-5c44486bf4-8xhgm      1/1     Running     0               98s
hmc-system           capa-controller-manager-fb8cf484b-qnsll                       1/1     Running     0               84s
hmc-system           capi-controller-manager-564745d4b-6dclz                       1/1     Running     0               3m14s
hmc-system           capv-controller-manager-5c8bbdb9b-4p4f9                       1/1     Running     0               92s
hmc-system           capz-controller-manager-59544898c6-hqdjw                      1/1     Running     0               98s
hmc-system           helm-controller-6455c6c9dd-qdlmr                              1/1     Running     0               8m3s
hmc-system           hmc-cert-manager-6d9d48d875-flg2c                             1/1     Running     0               5m13s
hmc-system           hmc-cert-manager-cainjector-75ddd76dbb-85j9z                  1/1     Running     0               5m13s
hmc-system           hmc-cert-manager-webhook-65c487759f-6l7r6                     1/1     Running     0               5m13s
hmc-system           hmc-cluster-api-operator-7b6676745d-mw69z                     1/1     Running     0               5m13s
hmc-system           hmc-controller-manager-578bdf5dd7-vwzzm                       1/1     Running     0               5m13s
hmc-system           hmc-system-hmc-controller-manager-8ccfbfc68-qwb44             1/1     Running     2 (3m26s ago)   8m3s
hmc-system           k0smotron-controller-manager-bootstrap-6865dc99cb-hxn7s       2/2     Running     0               2m27s
hmc-system           k0smotron-controller-manager-control-plane-7967fc8f84-8qjxx   2/2     Running     0               2m23s
hmc-system           k0smotron-controller-manager-infrastructure-84695547f-22w2f   2/2     Running     0               78s
hmc-system           source-controller-694fc6fcdf-zrls9                            1/1     Running     0               8m3s
kube-system          coredns-7c65d6cfc9-ks6ns                                      1/1     Running     0               8m54s
kube-system          coredns-7c65d6cfc9-qgftj                                      1/1     Running     0               8m54s
kube-system          etcd-kind-control-plane                                       1/1     Running     0               9m1s
kube-system          kindnet-n62g6                                                 1/1     Running     0               8m54s
kube-system          kube-apiserver-kind-control-plane                             1/1     Running     0               9m1s
kube-system          kube-controller-manager-kind-control-plane                    1/1     Running     0               9m1s
kube-system          kube-proxy-tq56q                                              1/1     Running     0               8m54s
kube-system          kube-scheduler-kind-control-plane                             1/1     Running     0               9m1s
local-path-storage   local-path-provisioner-57c5987fd4-rqzcm                       1/1     Running     0               8m54s
projectsveltos       access-manager-5c4b9558cb-w95zl                               1/1     Running     0               2m54s
projectsveltos       addon-controller-68bc495f47-c8qqz                             1/1     Running     0               2m54s
projectsveltos       classifier-manager-7786dfc5cc-wdqdk                           1/1     Running     0               2m54s
projectsveltos       conversion-webhook-f5cd4f665-6smhj                            1/1     Running     0               2m54s
projectsveltos       event-manager-96b576f96-5pzfb                                 1/1     Running     0               2m54s
projectsveltos       hc-manager-6549988dff-qtvpj                                   1/1     Running     0               2m54s
projectsveltos       register-mgmt-cluster-job-258mh                               0/1     Completed   0               2m54s
projectsveltos       sc-manager-5d79c8cdc5-wzc29                                   1/1     Running     0               2m54s
projectsveltos       shard-controller-bf6bb45cf-8zwbz                              1/1     Running     0               2m54s
projectsveltos       sveltos-agent-manager-6dbc465c8c-vj2zv                        1/1     Running     0               112s
sealed-secrets       sealed-secrets-controller-6f8b8b5495-6vn9j                    1/1     Running     0               8m11s
```

### Verify managed clusters status
```bash
$ kubectl get managedclusters.hmc.mirantis.com -Aw
NAMESPACE    NAME               READY   STATUS
hmc-system   soeren-cluster-1   True    ManagedCluster is ready
```

### Check the created resources in AWS
```bash
$ aws ec2 --region=us-east-1 describe-instances --query "Reservations[].Instances[].[InstanceId, Tags[?Key=='Name'].Value | [0]]" --filters "Name=tag:Name,Values=soeren-cluster-*" --output table

------------------------------------------------------------
|                     DescribeInstances                    |
+----------------------+-----------------------------------+
|  i-057cf18ab40f850fa |  soeren-cluster-1-cp-0            |
|  i-00047d395a1849e73 |  soeren-cluster-1-md-2crx2-7x2q4  |
|  i-0184962fe4854af54 |  soeren-cluster-2-md-9rkqm-tmdrt  |
|  i-06e4f4e6b48a1841c |  soeren-cluster-2-cp-2            |
|  i-0755fe63ec1664691 |  soeren-cluster-2-md-9rkqm-6v2gd  |
|  i-0125cb216f707c5de |  soeren-cluster-1-md-2crx2-4z564  |
|  i-0def1ec28e2388995 |  soeren-cluster-1-md-2crx2-gxfgt  |
|  i-0f571da657c671ad9 |  soeren-cluster-1-cp-1            |
|  i-089c452815a83b5af |  soeren-cluster-2-cp-1            |
|  i-0f861cb16f9d6ff1c |  soeren-cluster-2-cp-0            |
|  i-07f99b8f2f85b5925 |  soeren-cluster-1-cp-2            |
+----------------------+-----------------------------------+
```

### Cleaning up resources

Before starting to clean up the resources, flux reconciliation must be suspended, otherwise the cluster manifests be continuously re-applied.

```
# suspend kustomization of the clusters
$ flux suspend kustomization clusters-aws

# delete cluster manifests
$ k delete managedclusters.hmc.mirantis.com -n hmc-system soeren-cluster-1
$ k delete managedclusters.hmc.mirantis.com -n hmc-system soeren-cluster-2
```
