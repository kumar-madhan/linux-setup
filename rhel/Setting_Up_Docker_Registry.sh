# Pre-requisites
sudo yum install tree -y
sudo yum install httpd-tools -y
sudo yum update ca-certificates -y

# Step 1: Create Registry Directories
mkdir -p registry/{nginx,auth}
mkdir -p registry/nginx/{conf.d,ssl}
cd registry && tree

# Step 2: Create Docker Compose Manifest and Define Services
vi docker-compose.yaml

version: '3'
services:
  registry:
    image: registry:2
    restart: always
    ports:
    - "5000:5000"
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry-Realm
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/registry.passwd
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data
    volumes:
      - registrydata:/data
      - ./auth:/auth
    networks:
      - mynet
  nginx:
    image: nginx:alpine
    container_name: nginx
    restart: unless-stopped
    tty: true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d/:/etc/nginx/conf.d/
      - ./nginx/ssl/:/etc/nginx/ssl/
    networks:
      - mynet
networks:
  mynet:
    driver: bridge
volumes:
  registrydata:
    driver: local

# Step 3: Set up Nginx Port Forwarding
vi nginx/conf.d/registry.conf

upstream docker-registry {
    server registry:5000;
}
server {
    listen 80;
    server_name registry.example.com;
    return 301 https://registry.example.com$request_uri;
}
server {
    listen 443 ssl http2;
    server_name registry.example.com;
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    location / {
        if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" )  {
            return 404;
        }
        proxy_pass                          http://docker-registry;
        proxy_set_header  Host              $http_host;
        proxy_set_header  X-Real-IP         $remote_addr;
        proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header  X-Forwarded-Proto $scheme;
        proxy_read_timeout                  900;
    }
}

# Step 4: Increase Nginx File Upload Size
vi nginx/conf.d/additional.conf
client_max_body_size 2G;

# Step 5: Configure SSL Certificate and Basic Authentication
cp [path-to-file]/fullchain.pem nginx/ssl/
cp [path-to-file]/privkey.pem nginx/ssl/
cd auth

# Step 6: Add Root CA Certificate
    # Step 6.1: Convert Root CA Certificate to CRT format (if necessary)
    openssl x509 -in rootCA.pem -inform PEM -out rootCA.crt

    # Step 6.2: Copy Root CA Certificate to Docker Certificates Directory
    mkdir -p /etc/docker/certs.d/registry.example.com/
    cp rootCA.crt /etc/docker/certs.d/registry.example.com/

    # Step 6.3: Copy Root CA Certificate to System CA Certificates Directory
    mkdir -p /etc/pki/ca-trust/source/anchors/
    cp rootCA.crt /etc/pki/ca-trust/source/anchors/

    # Step 6.4: Update System CA Certificates
    update-ca-trust extract

    # Step 6.5: Restart Docker Service
    systemctl restart docker

# Step 7: Run Docker Registry
docker-compose up -d
docker-compose ps

# Push Docker Image to Private Registry
docker login https://registry.example.com/v2/
docker push registry.example.com/[new-image-name]
