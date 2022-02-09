#!/usr/bin/env sh
# @author      : ash 
# @created     : 01/02/2022
# @description : simply run project 
######################################################################

set -eux
export TF_STATE=.

terraform init 
terraform apply -auto-approve 
echo "Waiting a few seconds for vm to start..."
sleep 10 
./terraform-inventory -inventory > inventory.ini
ansible-playbook -i inventory.ini playbooks/all.yaml
