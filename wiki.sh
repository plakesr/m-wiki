#!/bin/bash

echo -e "\n"|ssh-keygen -t rsa -f /tmp/id_rsa -N ""

chmod 600 /tmp/id_rsa

terraform init && terraform apply -auto-approve

export mysql_ip=$(cat private_ip.txt |grep mysql | awk '{ print $5 }'|sed 's/.*=//')

export apache_ip=$(cat private_ip.txt |grep apache | awk '{ print $7 }'|sed 's/.*=//')



openssl rand -base64 6 > /tmp/matrix 

cat > ./ansible/hosts <<EOL
[web]
$apache_ip
[mysql]
$mysql_ip

[web:vars]
ansible_ssh_common_args="-o StrictHostKeyChecking=no"
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=/tmp/id_rsa

[mysql:vars]
ansible_ssh_common_args="-o StrictHostKeyChecking=no"
ansible_ssh_private_key_file=/tmp/id_rsa
ansible_ssh_user=ubuntu
EOL

ansible-vault encrypt --vault-password-file /tmp/matrix ansible/hosts

cat > ~/.ssh/config <<EOL
Host $mysql_ip
  ProxyCommand ssh -i /tmp/id_rsa ubuntu@'$apache_ip' nc %h %p
EOL


ansible-playbook -i ./ansible/hosts ansible/apache.yml --vault-password-file=/tmp/matrix

ansible-playbook -i ansible/hosts ansible/mysql.yml --vault-password-file=/tmp/matrix

cat > /tmp/wiki_config.txt <<EOL

Public IP : '$apache_ip'
MySql IP : '$mysql_ip'
DB_Name : my_wiki
DB_USER : wiki-user
DB_PASS: "Navigate to /tmp/mysql_wiki_pass.txt File."

EOL

echo "Your Configuration details are kept in /tmp/wiki_config.txt. Once you done with LocalSetting.php. Please execute the below command from M-WIKI directory. >>> \n ansible-playbook -i ansible/hosts ansible/local_set.yml --vault-password-file=/tmp/matrix"



