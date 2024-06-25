# argocd-gitops-demo
About A fully automated deployment using GitOps. Showcases multi namespaced environments and the progressive delivery

### Setup ArgoCD and required packages

shell
1. `chmod +x ./scripts/setup-argocd.sh` (if required)
2. `./setup-argocd.sh --memory 8192 --cpus 8`
    - this will install the required packages
    - port-forward argocd
    - get the default admin password
    - login via the cli
    - open argcd on the browser `http://localhost:8080`


### Github authentication with Github PAT
This is used for the demo, as it's very quick to setup and we don't have to create keys on individual computers.

- Generate a [Github PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

- Update the `password` in `argocd/application/nginx.yaml`

- Apply the secret and repository

`cd argocd && kubectl apply -k .` 

This will add a repository (authenticated) and an application that will reconcile/sync changes withing the `overlays/staging` application.


### Github Authentication via Private Key

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


### Apply the Application, Github repository authentication and the `overlays/staging` apps

1. `cd argocd && kubectl apply -k .`
This will create:
- Github secret, authenticating the repository
- The application and sync/provision any resource(s) within the `overlays/staging` directory.
