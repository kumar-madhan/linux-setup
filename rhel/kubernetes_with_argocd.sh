kubectl get nodes

# install argocd:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

watch kubectl get pods -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Configure Cluster Config
export KUBECONFIG=/home/madha/k8s-1-28-6-do-0-blr1-1715667007067-kubeconfig.yaml
kubectl -n argocd get all
watch kubectl get pods -n argocd

# install Brew Package Manager (Command line tool)
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/madha/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo yum groupinstall 'Development Tools'

# install argocd command line tool using brew package manager
brew install argocd

# get argocd password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
kubeclt get nodes

# get services under argocd namespace
kubectl get svc -n argocd

# set nodeport for argocd:
kubectl get svc argocd-server -n argocd -o=jsonpath='{.spec.ports[0].nodePort}'
kubectl expose deployment argocd-server --type=NodePort --name=argocd-server-nodeport -n argocd --port=80 --target-port=8080
kubectl get svc argocd-server-nodeport -n argocd -o=jsonpath='{.spec.ports[0].nodePort}'
# to get node ips
kubectl get nodes -o wide


# set LoadBalancer for argocd

# create loadbalancer
kubectl expose deployment argocd-server --type=LoadBalancer --name=argocd-server-lb -n argocd --port=80 --target-port=8080 # wait for 2 minutes

# to get Loadbalancer -ip or -hostname
kubectl get svc argocd-server-lb -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
kubectl get svc argocd-server-lb -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}'
