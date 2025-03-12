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
    kubectl create namespace gitlab

    helm repo add gitlab https://charts.gitlab.io/
    helm repo update
    helm upgrade --install gitlab gitlab/gitlab \
    --timeout 600s \
    --set global.edition=ce \
    --set global.hosts.domain=example.com \
    --set global.hosts.externalIP=0.0.0.0 \
    --set gitlab-runner.install="false" \
    --set certmanager.install="false" \
    --set global.ingress.configureCertmanager=false \
    --set global.hosts.https="false" \
    --version 8.5.2 \
    --namespace gitlab

    sleep 80s # check the kubectl wait thing
    kubectl port-forward svc/gitlab-webservice-default -n gitlab 8080:8181 &
    kubectl get secret gitlab-gitlab-initial-root-password  -n gitlab -o jsonpath="{.data.password}" | base64 --decode
}

main()
{
    install_helm
    install_gitlab
}

main
