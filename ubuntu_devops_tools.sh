#!/bin/bash

# Function to check if a command is available
function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Git
if ! command_exists git; then
  echo "Installing Git..."
  sudo apt update
  sudo apt install -y git
else
  echo "Git is already installed."
fi

# Install Docker
if ! command_exists docker; then
  echo "Installing Docker..."
  sudo apt update
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER
else
  echo "Docker is already installed."
fi

# Install Jenkins
if ! command_exists jenkins; then
  echo "Installing Jenkins..."
  wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
  sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  sudo apt update
  sudo apt install -y jenkins
else
  echo "Jenkins is already installed."
fi

# Install Ansible
if ! command_exists ansible; then
  echo "Installing Ansible..."
  sudo apt update
  sudo apt install -y ansible
else
  echo "Ansible is already installed."
fi

echo "DevOps tools installation completed."
