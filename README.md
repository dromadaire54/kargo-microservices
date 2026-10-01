# Kargo Microservices Demo

This is a GitOps repository of a Kargo Microservices example deploying.

## Overview

This example deploys the [GCP Microservices Demo](https://github.com/GoogleCloudPlatform/microservices-demo) in multiple stages. This examples features a single Warehouse which monitors 12 container repositories for new images. The Freight assembly feature can be used to mix and match container images of different versions, and promote them as a unit.

## Layout

```
charts/online-boutique/   Helm chart (all microservices, one image tag per service)
env/dev/values.yaml       dev stage overrides  -> namespace online-boutique-dev
env/prod/values.yaml      prod stage overrides -> namespace online-boutique-prod
kargo/                    Kargo Project, Warehouse and Stages
```

On promotion, each Stage clones the repo, writes the Freight's image tags into
`env/<stage>/values.yaml` (`image.tags.<service>`) with the `yaml-update` step,
then commits and pushes.

## Rendering

```sh
helm template online-boutique charts/online-boutique \
  -n online-boutique-dev -f env/dev/values.yaml
```

## Argo CD

Point one Application per stage at the chart with the stage's values file:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: online-boutique-dev
  namespace: argocd
  annotations:
    kargo.akuity.io/authorized-stage: kargo-microservices:dev
spec:
  project: default
  source:
    repoURL: https://github.com/jessesuen/kargo-microservices.git
    targetRevision: main
    path: charts/online-boutique
    helm:
      valueFiles:
      - ../../env/dev/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: online-boutique-dev
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
```
