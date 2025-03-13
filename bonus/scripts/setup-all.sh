#!/bin/bash

./setup-k3d.sh

echo "Creating Kubernetes cluster"
sudo k3d cluster create gitlab-cluster || { echo "Failed to create Kubernetes cluster"; exit 1; }

./setup-gitlab.sh
./setup-argocd.sh create
