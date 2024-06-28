# argocd-gitops-demo
About A fully automated deployment using GitOps. Showcases multi namespaced environments and the progressive delivery.

## Table of Contents
1. [To Get Started](#to-get-started)
2. [Detailed Information](#detailed-information)
   1. [Setup ArgoCD and Required Packages](#setup-argocd-and-required-packages)
   2. [Github Authentication with Github PAT](#github-authentication-with-github-pat)
   3. [Github Authentication via Private Key (optional)](#github-authentication-via-private-key-optional)
   4. [Kustomize](#kustomize)
   5. [Expose the App via Ingress and a Local Domain](#expose-the-app-via-ingress-and-a-local-domain)

## To Get Started
Run these scripts in order:
- `cd ./scripts`
- `chmod +x <script>` is required
- `./setup-argocd-and-enable-ingress.sh`
- `./argo-auth-application-sync.sh` (once you've done Github authentication with Github PAT)
- `./validate-nginx-app.sh`

## Detailed Information

### Setup ArgoCD and Required Packages
- `chmod +x ./scripts/setup-argocd.sh` (if required)
- `./setup-argocd.sh --memory 8192 --cpus 8`
  - This will install the required packages
  - Port-forward ArgoCD
  - Get the default admin password
  - Login via the CLI
  - Open ArgoCD in the browser `http://localhost:8080`

### Github Authentication with Github PAT
This is used for the demo, as it's very quick to set up and we don't have to create keys on individual computers.
- Generate a [Github PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- Update the password in `argocd/application/nginx.yaml`
- Apply the secret and repository
- Run the `argo-auth-application-sync.sh`
  - This will add a repository (authenticated) and an application that will reconcile/sync changes within the `overlays/staging` application(s) on the ArgoCD UI. You can login (you will find the admin password output on the terminal from running either script).
  - Can also run `kubectl get deployments -A && kubectl get services -A` and you will see the newly created deployment(s) and service(s) on the minikube cluster.

### Github Authentication via Private Key (optional)
To create a Kubernetes secret that uses an RSA private key for authentication with a GitHub repository, you need to create a Kubernetes secret with the label `argocd.argoproj.io/secret-type: repository`. This secret will contain the SSH private key and be used by ArgoCD to authenticate with the repository. Here's how you can set it up:
1. **Generate an SSH Key (if you don't already have one)**
   - If you don't have an SSH key pair, you can generate one using the following command:
     ```bash
     ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
     ```
   - This will create a private key (typically stored at `~/.ssh/
