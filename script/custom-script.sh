#!/usr/bin/env bash

set -eux

# Sample custom configuration script - add your own commands here
# to add some additional commands for your environment
#
# For example:
# yum install -y curl wget git tmux firefox xvfb
echo "Installing Updates"
#Installing updates
yum -y update
echo "Installing Packages"
#Installing Packages
yum -y install wget nano emacs vim

echo "Installing Docker Repo"
#Installing Docker Repo
tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

echo "Installing docker-engine"
#Installing docker-engine
yum -y install docker-engine

echo "Installing docker-compose"
#Installing docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

echo "Installing docker-machine"
#Installing docker-machine
curl -L https://github.com/docker/machine/releases/download/v0.8.2/docker-machine-`uname -s`-`uname -m` > /usr/bin/docker-machine
chmod +x /usr/bin/docker-machine

echo "creating local_repo"
yum install createrepo -y
mkdir -p /local_repo/puppet4
createrepo /local_repo

echo "Enabling puppet Repository"
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

echo "Adding puppet4 packages and dependency to local_repo"
yum install --downloadonly --downloaddir=/local_repo/puppet4 puppetserver puppet-agent
yum install --downloadonly --downloaddir=/local_repo ntp httpd mariadb-server mariadb php php-mysql php-fpm php-common php-cli php-dba

echo "Adding Repo Entry"
sudo tee /etc/yum.repos.d/local_repo.repo <<-'EOF'
[local_repo]
name=local Repository
baseurl=file:///local_repo
enabled=1
gpgcheck=0
EOF

echo "Updating local_repo"
createrepo --update /local_repo
