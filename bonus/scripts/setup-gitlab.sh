#!/bin/bash

log_info() {
    echo -e "\033[1;34mINFO:\033[0m $1"
}

log_success() {
    echo -e "\033[1;32mSUCCESS:\033[0m $1"
}

log_error() {
    echo -e "\033[1;31mERROR:\033[0m $1"
    exit 1
}

install_helm()
{
    if ! command -v helm >/dev/null 2>&1; then   
        curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
        sudo apt-get install apt-transport-https --yes
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
        sudo apt-get update
        sudo apt-get install helm
    else
        log_success "Helm is already installed."
    fi
}

install_gitlab()
{
    sudo kubectl create namespace gitlab

    sudo helm repo add gitlab https://charts.gitlab.io/
    sudo helm repo update
    sudo helm upgrade --install gitlab gitlab/gitlab \
    --set global.edition=ce \
    --set global.hosts.domain=localhost \
    --set certmanager-issuer.email=me@localhost.com \
    --timeout 600s \
    --namespace gitlab

    sudo kubectl wait --for=condition=ready --timeout=300s pod -l app=webservice -n gitlab 
    sudo kubectl get secret gitlab-gitlab-initial-root-password  -n gitlab -o jsonpath="{.data.password}" | base64 --decode > gitlab-pass.txt
    sudo kubectl port-forward --address=0.0.0.0 svc/gitlab-nginx-ingress-controller -n gitlab 443:443
}

main()
{
    install_helm
    install_gitlab
}

main
