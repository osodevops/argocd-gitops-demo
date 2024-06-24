# argocd-gitops-demo
About A fully automated deployment using GitOps. Showcases multi namespaced environments and the progressive delivery

### Setup ArgoCD and required packages

```shell
1. chmod +x ./scripts/setup-argocd.sh (if required)
2. ./setup-argocd.sh --memory 8192 --cpus 8