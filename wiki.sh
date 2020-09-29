#!/bin/bash

echo -e "\n"|ssh-keygen -t rsa -f /tmp/id_rsa -N ""

chmod 600 /tmp/id_rsa

terraform init && terraform apply -auto-approve

export mysql_ip=$(cat private_ip.txt |grep mysql | awk '{ print $5 }'|sed 's/.*=//')

export apache_ip=$(cat private_ip.txt |grep apache | awk '{ print $7 }'|sed 's/.*=//')

cat > /tmp/wiki_config.txt <<EOL

Public IP : '$apache_ip'
MySql IP : '$mysql_ip'
DB_Name : my_wiki
DB_USER : wiki-user
DB_PASS: Corona@321
EOL

cat > ~/.ssh/matrix <<EOL
ansible_sec@123
EOL


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

ansible-vault encrypt --vault-password-file ~/.ssh/matrix ansible/hosts
ansible-vault encrypt --vault-password-file ~/.ssh/matrix ansible/mysql.yml

cat > ~/.ssh/config <<EOL
Host $mysql_ip
  ProxyCommand ssh -i /tmp/id_rsa ubuntu@'$apache_ip' nc %h %p
EOL


ansible-playbook -i ./ansible/hosts ansible/apache.yml 

ansible-playbook -i ansible/hosts ansible/mysql.yml --vault-password-file ~/.ssh/matrix

echo "Your Configuration details are kept in /tmp/wiki_config.txt. Once you done with LocalSetting.php. Please execute the below command from M-WIKI directory. >>> \n ansible-playbook -i ansible/hosts ansible/local_set.yml"



