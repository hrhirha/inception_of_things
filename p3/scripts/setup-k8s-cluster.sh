#!/bin/bash

# Define text styles for bold and normal
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Function to create resources
create_resources() {
    echo "Creating Kubernetes cluster and namespaces..."
    sudo k3d cluster create iot-cluster || { echo "Failed to create Kubernetes cluster"; exit 1; }

    sudo kubectl create namespace argocd
    sudo kubectl create namespace dev

    echo "Installing ArgoCD..."
    sudo kubectl -n argocd apply -f \
        https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    sudo kubectl wait --for=condition=ready --timeout=300s pod --all -n argocd # Allow time for ArgoCD to initialize

    echo "Applying custom ArgoCD configuration..."
    sudo kubectl -n argocd apply -f ../confs/argocd-application.yaml

    echo "Retrieving ArgoCD admin password..."
    sudo kubectl -n argocd get secret argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" | base64 -d > argo-pass.txt
    echo "Password saved to argo-pass.txt"

    while sudo kubectl get pods -n dev 2>&1 | grep -q 'No resources found in dev namespace'; do
        sleep 5
    done
    sudo kubectl wait --for=condition=ready --timeout=300s pod --all -n dev # Allow time for App to initialize

    echo "Starting port forwarding..."
    sudo nohup kubectl port-forward svc/argocd-server -n argocd 8181:443 &
    sudo nohup kubectl port-forward svc/wil-playground-service -n dev 8282:80 &

    echo "Resources successfully created!"
}

# Function to delete resources
delete_resources() {
    echo "Deleting Kubernetes namespaces..."
    sudo kubectl delete namespace argocd
    sudo kubectl delete namespace dev
    sudo k3d cluster delete iot-cluster

    echo "Cleaning up temporary files and processes..."
    rm -f argo-pass.txt
    sudo pkill -f "sudo kubectl port-forward" || echo "No port-forward processes to kill."

    echo "Resources successfully deleted!"
}

# Display usage instructions
show_usage() {
    echo "Usage:"
    echo " $0 ${BOLD}create${NORMAL} | ${BOLD}delete${NORMAL}"
}

# Main script logic
case $1 in
    create)
        create_resources
        ;;
    delete)
        delete_resources
        ;;
    *)
        echo "Invalid option!"
        show_usage
        exit 1
        ;;
esac
