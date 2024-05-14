#!/bin/bash

install_git() {
    echo "Installing Git..."
    # Add commands to install Git here
    sudo yum install -y git
}

install_ansible() {
    echo "Installing Git..."
    # Add commands to install Git here
    sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    sudo yum install -y ansible

}

install_jenkins() {
    echo "Installing Git..."
    # Add commands to install Git here
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum upgrade -y
    # Add required dependencies for the jenkins package
    sudo yum install -y fontconfig java-17-openjdk
    sudo yum install -y jenkins
    sudo systemctl daemon-reload
}

install_terraform() {
    echo "Installing Terraform..."
    # Add commands to install Terraform here
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform
}

install_docker() {
    # Removing Previously installed docker Dependancies
    sudo yum remove docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-engine

    # Adding Docker Repo
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # Installing Docker Engine
    sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
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
