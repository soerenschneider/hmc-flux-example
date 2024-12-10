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
│   ├── flux-system
│   ├── hmc-system
│   └── sealed-secrets
└── management-clusters         # clusters managed by flux
    └── kind                    # local test cluster provided by "kind"
        ├── hmc
        └── infra
```

### Kustomize manifests
Before checking out the kustomize manifests, [this FAQ entry](https://fluxcd.io/flux/faq/#are-there-two-kustomization-types) should be read first.

The example kind cluster defines two `kustomize.toolkit.fluxcd.io/v1` [manifests](management-clusters/kind/flux-kustomization.yaml), one to install infra components including CRDs and one to install everything else.

Define `kustomization.kustomize.config.k8s.io` manifests in the appropriate `management-clusters` to patch kustomize bases. An example that patches a `ManagedCluster` resource is found [here](management-clusters/kind/hmc/kustomization.yaml).

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
NAMESPACE            NAME                                                      READY   STATUS    RESTARTS   AGE
flux-system          helm-controller-7f788c795c-stsmf                          1/1     Running   0          74s
flux-system          kustomize-controller-b4f45fff6-56xw5                      1/1     Running   0          74s
flux-system          notification-controller-556b8867f8-pt9kb                  1/1     Running   0          74s
flux-system          source-controller-77d6cd56c9-cvt26                        1/1     Running   0          74s
hmc-system           hmc-system-hmc-cert-manager-7bd5d57d56-6dpb5              1/1     Running   0          37s
hmc-system           hmc-system-hmc-cert-manager-cainjector-75df9fc549-h7zxf   1/1     Running   0          37s
hmc-system           hmc-system-hmc-cert-manager-webhook-65955b48f6-szmxc      1/1     Running   0          37s
hmc-system           hmc-system-hmc-controller-manager-8ccfbfc68-m2v4q         1/1     Running   0          37s
kube-system          coredns-7c65d6cfc9-2mzfw                                  1/1     Running   0          79s
kube-system          coredns-7c65d6cfc9-wk4fz                                  1/1     Running   0          79s
kube-system          etcd-kind-control-plane                                   1/1     Running   0          87s
kube-system          kindnet-8rcvz                                             1/1     Running   0          79s
kube-system          kube-apiserver-kind-control-plane                         1/1     Running   0          86s
kube-system          kube-controller-manager-kind-control-plane                1/1     Running   0          86s
kube-system          kube-proxy-qztft                                          1/1     Running   0          79s
kube-system          kube-scheduler-kind-control-plane                         1/1     Running   0          87s
local-path-storage   local-path-provisioner-57c5987fd4-bnzgs                   1/1     Running   0          79s
sealed-secrets       sealed-secrets-controller-6f8b8b5495-55hzx                1/1     Running   0          39s
```
