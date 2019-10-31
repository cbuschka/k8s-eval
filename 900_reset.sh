#!/bin/bash

set -e

node=${1}
if [ -z "${node}" ]; then
  echo "`basename $0` <config-name>"
  exit 1
fi

config_file=$(dirname $0)/config.d/${node}
if [ ! -f "${config_file}" ]; then
  echo "No config file ${config_file}."
  exit 1
fi

source $(dirname $0)/config.d/cluster
source ${config_file}
source $(dirname $0)/lib.include.sh

printBanner "Resetting..."
ssh ${user}@${host} "
echo 'echo Resetting k8s cluster...'
kubeadm reset
echo 'Cleaning firewall rules...'
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
rm -rf /etc/kubernetes/
echo 'Done.'
"

exit $?
