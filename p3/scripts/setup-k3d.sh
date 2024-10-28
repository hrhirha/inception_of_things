#!/bin/bash

sudo apt update -y

# installing docker 
if ! command -v docker 2>&1 >/dev/null
then
	if ! command -v curl 2>&1 >/dev/null
	then
		sudo apt install curl -y
	fi

	sudo mkdir /etc/apt/keyrings 2>/dev/null
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
	sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo groupadd docker 2>/dev/null
	sudo usermod -aG docker $USER
	newgrp docker
else
	echo "docker is installed"
fi

# installing kubectl
if ! command -v kubectl 2>&1 >/dev/null
then
	sudo apt install -y apt-transport-https ca-certificates gnupg
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
	sudo apt update
	sudo apt install -y kubectl
else
	echo "kubectl is installed"
fi

# installing k3d
if ! command -v k3d 2>&1 >/dev/null
then
	wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
	echo "k3d is installed"
fi