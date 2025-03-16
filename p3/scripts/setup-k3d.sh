#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Helper Functions
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

# Update system packages
update_system() {
    log_info "Updating system packages..."
    sudo apt update -y || log_error "Failed to update packages."
    log_success "System updated."
}

# Install Docker
install_docker() {
    log_info "Checking for Docker installation..."
    if ! command -v docker >/dev/null 2>&1; then
        log_info "Installing Docker..."
        # Ensure curl is installed
        if ! command -v curl >/dev/null 2>&1; then
            log_info "Installing curl..."
            sudo apt install curl -y || log_error "Failed to install curl."
        fi

        # Add Docker repository and install Docker
        sudo mkdir -p /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || log_error "Failed to install Docker."

        log_success "Docker installed successfully."
    else
        log_success "Docker is already installed."
    fi
}

# Install Kubectl
install_kubectl() {
    log_info "Checking for Kubectl installation..."
    if ! command -v kubectl >/dev/null 2>&1; then
        log_info "Installing Kubectl..."
        sudo apt install -y apt-transport-https ca-certificates gnupg || log_error "Failed to install prerequisites for Kubectl."
        
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg || log_error "Failed to fetch Kubectl key."

        echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | \
        sudo tee /etc/apt/sources.list.d/kubernetes.list

        sudo apt update
        sudo apt install -y kubectl || log_error "Failed to install Kubectl."

        log_success "Kubectl installed successfully."
    else
        log_success "Kubectl is already installed."
    fi
}

# Install K3d
install_k3d() {
    log_info "Checking for K3d installation..."
    if ! command -v k3d >/dev/null 2>&1; then
        log_info "Installing K3d..."
        wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash || log_error "Failed to install K3d."
        log_success "K3d installed successfully."
    else
        log_success "K3d is already installed."
    fi
}

# Main Execution
main() {
    update_system
    install_docker
    install_kubectl
    install_k3d
    log_success "All tools are installed and ready to use!"
}

# Run the script
main
