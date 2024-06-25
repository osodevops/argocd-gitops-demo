# argocd-gitops-demo
About A fully automated deployment using GitOps. Showcases multi namespaced environments and the progressive delivery

### Setup ArgoCD and required packages

-  `chmod +x ./scripts/setup-argocd.sh` (if required)
-  `./setup-argocd.sh --memory 8192 --cpus 8`
    - this will install the required packages
    - port-forward argocd
    - get the default admin password
    - login via the cli
    - open argcd on the browser `http://localhost:8080`


### Github authentication with Github PAT
This is used for the demo, as it's very quick to setup and we don't have to create keys on individual computers.

- Generate a [Github PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

- Update the password in `argocd/application/nginx.yaml`

- Apply the secret and repository

- run the `argo-auth-application-sync.sh`

This will add a repository (authenticated) and an application that will reconcile/sync changes within the `overlays/staging` application(s) on the ArgoCD UI. You can login (you will find the admin password output on the terminal from running either script).

Can also run `kubectl get deployments -A && kubectl get services -A` and you will see the newly created deployment(s) and service(s) on the minikube cluster.


### Github Authentication via Private Key (optional)

To create a Kubernetes secret that uses an RSA private key for authentication with a GitHub repository, you need to create a Kubernetes secret with the label argocd.argoproj.io/secret-type: repository. This secret will contain the SSH private key and be used by ArgoCD to authenticate with the repository. Here's how you can set it up:

1. Generate an SSH Key (if you don't already have one)
If you don't have an SSH key pair, you can generate one using the following command:

```
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```
This will create a private key (typically stored at `~/.ssh/id_rsa)` and a public key `(~/.ssh/id_rsa.pub)`

2. Add the Public Key to Your GitHub Repository
Go to your GitHub repository, navigate to Settings > Deploy keys, and add the contents of your id_rsa.pub file.

3. Update the `./argocd/repositories/private_git_authentication.yaml` with the private key typically found in `~/.ssh/id_rsa`

