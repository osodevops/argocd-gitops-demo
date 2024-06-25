#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
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

# Log in to Argo CD CLI
echo "Logging in to Argo CD CLI..."
argocd login localhost:8080 --username admin --password "${argocd_password}" --insecure

# Retry port-forwarding up to 3 times if it fails
MAX_RETRIES=3
RETRY_COUNT=0
PORT_FORWARD_SUCCESS=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Exposing Argo CD server on port 8080 (Attempt $((RETRY_COUNT+1))/$MAX_RETRIES)..."
    kubectl -n argocd port-forward svc/argocd-server 8080:80 &
    PORT_FORWARD_PID=$!
    sleep 5
    
    # Check if port-forwarding is working
    if lsof -i :8080 &>/dev/null; then
        PORT_FORWARD_SUCCESS=1
        break
    else
        kill $PORT_FORWARD_PID
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep 5
    fi
done

if [ $PORT_FORWARD_SUCCESS -ne 1 ]; then
    echo "Failed to set up port-forwarding for Argo CD after $MAX_RETRIES attempts. Exiting..."
    exit 1
fi

echo "Argo CD setup completed successfully!"

