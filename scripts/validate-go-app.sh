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

# Function to check if minikube tunnel is already running
is_minikube_tunnel_running() {
    pgrep -f "minikube tunnel" >/dev/null 2>&1
}

# Run minikube tunnel if it's not already running
if is_minikube_tunnel_running; then
    echo "Minikube tunnel is already running."
else
    echo "Starting minikube tunnel..."
    minikube tunnel &
    TUNNEL_PID=$!

    # Wait for tunnel to stabilize
    sleep 10
fi

# Validate the service response for Go app
GO_APP_HOST="go.example"
GO_APP_PORT=80

echo "Validating the service response for Go app..."
RESPONSE=$(curl --resolve "${GO_APP_HOST}:${GO_APP_PORT}:127.0.0.1" -s -o /dev/null -w "%{http_code}" "http://${GO_APP_HOST}:${GO_APP_PORT}")

if [ "$RESPONSE" -eq 200 ]; then
    echo "Service is returning the expected response."
    
    # Update /etc/hosts
    echo "Updating /etc/hosts..."
    if grep -q "127.0.0.1 ${GO_APP_HOST}" /etc/hosts; then
        echo "/etc/hosts already contains the entry."
    else
        echo "127.0.0.1 ${GO_APP_HOST}" | sudo tee -a /etc/hosts > /dev/null
        echo "/etc/hosts updated successfully."
    fi

    # Open in default browser
    echo "Opening ${GO_APP_HOST}:${GO_APP_PORT} in the default browser..."
    open_browser "http://${GO_APP_HOST}"

    echo "Process completed successfully!"
else
    echo "Service did not return the expected response. Response code: $RESPONSE"
    echo "Cleaning up..."
    if [ ! -z "$TUNNEL_PID" ]; then
        kill $TUNNEL_PID
    fi
    exit 1
fi
