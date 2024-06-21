# argocd-gitops-demo
About A fully automated deployment using GitOps. Showcases multi namespaced environments and the progressive delivery

### Kube commands

```shell
1. Start the minikube cluster: `minikube start --cpus=6 --memory=20019`
2. Deploy the correct cluster manifests: `kubectl apply -k ./clusters/staging`
```
