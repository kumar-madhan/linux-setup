#!/bin/bash

install_git() {
    echo "Installing Git..."
    sudo yum install -y git
}

install_ansible() {
    echo "Installing Ansible..."
    sudo yum install -y epel-release
    sudo yum install -y ansible
}

install_jenkins() {
    echo "Installing Jenkins..."
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum upgrade -y
    sudo yum install -y fontconfig java-17-openjdk
    sudo yum install -y jenkins
    sudo systemctl daemon-reload
    sudo systemctl enable --now jenkins
}

install_terraform() {
    echo "Installing Terraform..."
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform
}

install_docker() {
    echo "Installing Docker..."
    # Removing Previously installed Docker dependencies
    sudo yum remove -y docker \
                        docker-client \
                        docker-client-latest \
                        docker-common \
                        docker-latest \
                        docker-latest-logrotate \
                        docker-logrotate \
                        docker-engine

    # Adding Docker repo
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # Installing Docker Engine
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 [git|jenkins|ansible|terraform|docker]"
    exit 1
fi

case "$1" in
    git)
        install_git
        ;;
    jenkins)
        install_jenkins
        ;;
    ansible)
        install_ansible
        ;;
    terraform)
        install_terraform
        ;;
    docker)
        install_docker
        ;;
    *)
        echo "Unknown tool: $1"
        exit 1
        ;;
esac
