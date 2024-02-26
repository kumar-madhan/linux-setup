#!/bin/bash

# Function to check if a command is available
function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

sudo yum update -y

# Install Git
if ! command_exists git; then
  echo "Installing Git..."
  sudo yum install -y git
else
  echo "Git is already installed."
fi

# Install Docker
if ! command_exists docker; then
  echo "Installing Docker..."
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  
  sudo yum install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $(whoamin)
else
  echo "Docker is already installed."
fi

# Install Jenkins
if ! command_exists jenkins; then
  echo "Installing Jenkins..."
  wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
  sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  sudo yum update
  sudo yum install -y jenkins
else
  echo "Jenkins is already installed."
fi

# Install Ansible
if ! command_exists ansible; then
  echo "Installing Ansible..."
  sudo yum update
  sudo yum install -y ansible
else
  echo "Ansible is already installed."
fi

echo "DevOps tools installation completed."
