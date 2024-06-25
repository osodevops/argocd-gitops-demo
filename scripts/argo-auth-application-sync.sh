# Apply Kustomize configuration
echo "Applying Kustomize configuration..."
kubectl apply -k ../argocd

if [ $? -ne 0 ]; then
    echo "Failed to apply Kustomize configuration. Exiting..."
    exit 1
fi

echo "Argo CD setup completed successfully!"

argocd_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Reminder of the admin admin password: ${argocd_password}"

echo "Access the Argo CD UI at http://localhost:8080"