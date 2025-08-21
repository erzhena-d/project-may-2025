#!/bin/bash
#step 1 - prepare vm (install terraform and ansible)
#step 2 - run terraform code
#step 3 - get ip from terraform output and update hosts file
#step 4 - run ansible playbook to configure vm


function prepare_vm() {
    sudo apt update
    sudo apt install ansible -y
    if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg]
    then
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    fi
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
}
prepare_vm

function run_terraform() {
    cd terraform
    terraform init
    terraform apply -auto-approve
}
run_terraform

function update_hosts() {
    terraform output -raw ec2 > ../ansible/hosts
}
update_hosts

function install_apps() {
    cd ../ansible
    ansible-playbook main.yml
}
install_apps