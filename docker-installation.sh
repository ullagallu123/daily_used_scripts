#!/bin/bash
#!/bin/bash

# Update packages and install necessary software
dnf install -y git docker tmux

# Start Docker service and add ec2-user to the docker group
systemctl start docker
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Run commands as ec2-user to ensure `git clone` works in the correct user context
sudo -u ec2-user bash <<EOF

# Define the target directory
TARGET_DIR="/home/ec2-user/ibm-instana"

# Check if the directory exists and is a Git repository
if [ -d "\$TARGET_DIR/.git" ]; then
  # If it's already a Git repository, pull the latest changes
  cd "\$TARGET_DIR"
  git pull
else
  # Otherwise, clone the repository fresh
  git clone https://github.com/instana-srk/ibm-instana.git "\$TARGET_DIR"
fi

EOF



# curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# chmod +x kubectl
# mv kubectl /usr/local/bin

# sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
# sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
# sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# sudo yum install java-21-amazon-corretto-devel

# cd /opt

# wget https://archive.apache.org/dist/maven/maven-3/3.9.8/binaries/apache-maven-3.9.8-bin.tar.gz

# mkdir -p maven

# tar -xvzf apache-maven-3.9.8-bin.tar.gz -C maven

# echo 'export PATH=/opt/maven/bin:"$PATH"' >> /home/ec2-user/.bash_profile

# source /home/ec2-user/.bash_profile


# minikube start --network-plugin=cni --cni=calico
