#!/bin/bash

# Update system
apt-get update -y
apt-get install -y docker.io git curl

# Start Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Create Jenkins home and init folder
mkdir -p /opt/jenkins_home/init.groovy.d

# Download Groovy script, plugins.txt, and Jenkinsfile from GitHub raw
curl -o /opt/jenkins_home/init.groovy.d/create-pipeline.groovy https://raw.githubusercontent.com/gowthamchi/CI-CD-Automation/main/jenkins/create-pipeline.groovy
curl -o /opt/jenkins_home/plugins.txt https://raw.githubusercontent.com/gowthamchi/CI-CD-Automation/main/jenkins/plugins.txt
curl -o /opt/jenkins_home/Jenkinsfile https://raw.githubusercontent.com/gowthamchi/CI-CD-Automation/main/jenkins/Jenkinsfile

# Run Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -v /opt/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Wait for Jenkins to initialize
sleep 60

# Install Jenkins plugins listed in plugins.txt
PLUGINS=$(cat /opt/jenkins_home/plugins.txt | xargs)
docker exec jenkins bash -c "/usr/local/bin/install-plugins.sh $PLUGINS"

# Restart Jenkins to load plugins
docker restart jenkins
