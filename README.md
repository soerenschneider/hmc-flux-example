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

## Bootstrapping flux

A local management cluster can be spun up using only two requirements, [kind](https://kind.sigs.k8s.io/) and a recent version of [kubectl](https://kubernetes.io/docs/reference/kubectl/).

```
# Spin up testcluster using "kind"
$ kind create cluster

# CRDs of flux are not available in the first run
$ kubectl apply -k management-clusters/kind; kubectl apply -k management-clusters/kind

# Watch manifests are being applied
$ kubectl get pods -Aw
```

After some time has passed, the state of the cluster should look like this:

```
$ kubectl get pods -A
NAMESPACE            NAME                                                          READY   STATUS      RESTARTS        AGE
cert-manager         cert-manager-b6fd485d9-65qjd                                  1/1     Running     0               8m13s
cert-manager         cert-manager-cainjector-dcc5966bc-jkhtk                       1/1     Running     0               8m13s
cert-manager         cert-manager-webhook-dfb76c7bd-c8krs                          1/1     Running     0               8m13s
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
