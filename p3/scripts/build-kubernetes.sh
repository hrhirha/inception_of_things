#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

if [[ $1 == "create" ]]
then
    k3d cluster create tbd-cluster

    kubectl create namespace argocd
    kubectl create namespace dev

    kubectl -n argocd apply -f \
            https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    sleep 40
    kubectl -n argocd apply -f ../confs/argocd-application.yaml
    sleep 10
    kubectl -n argocd get secret argocd-initial-admin-secret \
            -o jsonpath="{.data.password}" | base64 -d > argo-pass.txt

    kubectl port-forward svc/wil-playground-service -n dev 8888:80 &
    kubectl port-forward svc/argocd-server -n argocd 8080:443 &

    clear && echo "done creating resources"
elif [[ $1 == "delete" ]]
then
    kubectl delete namespace argocd
    kubectl delete namespace dev

    rm ./argo-pass.txt
    killall kubectl

    clear && echo "done deleting resources"
else
    echo "Usage:"
    echo " $0 ${bold}create${normal}|${bold}delete${normal}"
fi