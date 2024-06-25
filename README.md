# argocd-gitops-demo
About A fully automated deployment using GitOps. Showcases multi namespaced environments and the progressive delivery

### Setup ArgoCD and required packages

```shell
1. chmod +x ./scripts/setup-argocd.sh (if required)
2. ./setup-argocd.sh --memory 8192 --cpus 8
    - this will install the required packages


# Github Authentication via Private Key

To create a Kubernetes secret that uses an RSA private key for authentication with a GitHub repository, you need to create a Kubernetes secret with the label argocd.argoproj.io/secret-type: repository. This secret will contain the SSH private key and be used by ArgoCD to authenticate with the repository. Here's how you can set it up:

1. Generate an SSH Key (if you don't already have one)
If you don't have an SSH key pair, you can generate one using the following command:

```
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
This will create a private key (typically stored at ~/.ssh/id_rsa) and a public key (~/.ssh/id_rsa.pub).
```

2. Add the Public Key to Your GitHub Repository
Go to your GitHub repository, navigate to Settings > Deploy keys, and add the contents of your id_rsa.pub file.

3. Update the `./argocd/repositories/private_git_authentication.yaml` with the private key typically found in `~/.ssh/id_rsa`

4. `kubectl apply -f private_git_authentication.yaml`
