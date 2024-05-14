# Step 1: Update and Install Required Tools
sudo yum update
sudo yum install vim wget curl -y
sudo yum install wget unzip -y

# Step 2: Create User for SonarQube
sudo useradd sonar
sudo passwd sonar

# Step 3: Install Java on CentOS 8
sudo yum install java-11-openjdk-devel
sudo update-alternatives --config java
java –version

# Step 4: Install and Setup PostgreSQL 14 Database For SonarQube
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf -y install postgresql14 postgresql14-server
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
sudo systemctl start postgresql-14
sudo systemctl enable postgresql-14
sudo passwd postgres
su -- postgres
createuser sonar
psql
ALTER USER sonar WITH ENCRYPTED password 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
grant all privileges on sonarqube to sonar;
\q
exit

# Step 5: Download and Install SonarQube on CentOS 8
cd /tmp
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.1.0.47736.zip
sudo unzip sonarqube-9.1.0.47736.zip -d /opt
sudo mv /opt/sonarqube-9.1.0.47736 /opt/sonarqube

# Step 6: Configure SonarQube
sudo groupadd sonar
sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar
sudo chown -R sonar:sonar /opt/sonarqube
sudo vim /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=your_user
sonar.jdbc.password=your_password
sudo vim /opt/sonarqube/bin/linux-x86-64/sonar.sh
RUN_AS_USER=sonar

# Step 7: Start SonarQube
sudo su sonar
cd /opt/sonarqube/bin/linux-x86-64/
./sonar.sh start
./sonar.sh status

# Step 8: SonarQube Logs
sudo mv /opt/sonarqube/logs/sonar.20220127.log /opt/sonarqube/logs/sonar.log
tail /opt/sonarqube/logs/sonar.log

# Step 9: Configure Systemd Service
sudo nano /etc/systemd/system/sonar.service
# Add the following lines:

[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target

# Then:
sudo systemctl start sonar
sudo systemctl enable sonar
sudo systemctl status sonar

# Step 10: Access SonarQube
# Visit http://localhost:9000 in your web browser.