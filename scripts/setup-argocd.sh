#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to open URL in the default browser
open_browser() {
    case "$OSTYPE" in
        darwin*) open "$1" ;;  # MacOS
        linux*) xdg-open "$1" ;;  # Linux
        *) echo "Cannot open URL on this OS. Please open $1 manually." ;;
    esac
}

# Function to parse command-line arguments for memory and CPU
parse_args() {
    MEMORY="6144"
    CPUS="6"
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --memory) MEMORY="$2"; shift 2 ;;
            --cpus) CPUS="$2"; shift 2 ;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
    done
}

# Parse command-line arguments
parse_args "$@"

# Install Homebrew if not installed
if ! command_exists brew; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install Minikube if not installed
if ! command_exists minikube; then
    echo "Minikube not found. Installing Minikube..."
    brew install minikube
else
    echo "Minikube is already installed."
fi

# Install kubectl if not installed
if ! command_exists kubectl; then
    echo "kubectl not found. Installing kubectl..."
    brew install kubectl
else
    echo "kubectl is already installed."
fi

# Start Minikube with specified memory and CPU
echo "Starting Minikube with ${MEMORY}MB memory and ${CPUS} CPUs..."
minikube start --memory=${MEMORY} --cpus=${CPUS}

# Check if Minikube started successfully
if [ $? -ne 0 ]; then
    echo "Failed to start Minikube. Exiting..."
    exit 1
fi

# Install Argo CD
echo "Creating namespace 'argocd' for Argo CD..."
kubectl create namespace argocd

echo "Applying Argo CD manifests..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Check if Argo CD was applied successfully
if [ $? -ne 0 ]; then
    echo "Failed to apply Argo CD manifests. Exiting..."y
    exit 1
fi

# Wait for Argo CD server to be running
echo "Waiting for Argo CD server to be ready..."
until kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].status.phase}' | grep -q 'Running'; do
  echo -n "."
  sleep 5
done
echo "Argo CD server is running."

# Check if port-forwarding was set up successfully
if [ $? -ne 0 ]; then
    echo "Failed to set up port-forwarding for Argo CD. Exiting..."
    exit 1
fi

# Wait for the initial admin secret to be created
echo "Waiting for initial admin secret..."
until kubectl -n argocd get secret argocd-initial-admin-secret &> /dev/null; do
  echo -n "."
  sleep 5
done
echo "Initial admin secret is available."

# Get the initial admin password
echo "Retrieving initial admin password..."
argocd_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Initial admin password: ${argocd_password}"

# Check if login was successful
if [ $? -ne 0 ]; then
    echo "Failed to log in to Argo CD CLI. Exiting..."
    exit 1
fi

# Expose Argo CD server
# & run in background, allowing the script to continue...
echo "Exposing Argo CD server on port 8080..."
kubectl -n argocd port-forward svc/argocd-server 8080:80 & 

# Log in to Argo CD CLI
echo "Logging in to Argo CD CLI..."
argocd login localhost:8080 --username admin --password "${argocd_password}" --insecure

echo "Argo CD setup completed successfully!"
echo "Access the Argo CD UI at http://localhost:8080"

# Open the Argo CD UI in the default browser
open_browser "http://localhost:8080"

# Clean up port-forwarding process on exit
trap "kill $(jobs -p)" EXIT
