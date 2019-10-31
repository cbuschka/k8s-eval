#!/bin/bash

set -e

source $(dirname $0)/config.d/cluster
source $(dirname $0)/lib.include.sh

if [ ! "${USER}" = "root" ]; then
  echo "Run with sudo or as root."
  exit 1
fi

printBanner "Installing tools..."
cat - > /etc/yum.repos.d/kubernetes.repo <<EOB
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOB
yum install -y kubectl

exit $?

