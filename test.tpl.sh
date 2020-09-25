#!/bin/bash

export PRIVATE_ADDRESS = ${private_address} >> /tmp/iplist


echo PRIVATE1_ADDRESS = ${private_address} >> /tmp/iplist


cat > /tmp/hosts <<EOL
${private_address} 
EOL


#############Ansible-install##########
echo $PRIVATE_ADDRESS
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y


################CRON###############
cat > /tmp/cron.sh <<EOL
#!/bin/bash
rm -rf /opt/m-wiki
git -C /opt clone https://github.com/plakesr/m-wiki.git 
cp -rvf /opt/m-wiki/LocalSettings.php /var/www/html/LocalSettings.php
EOL


###################Ansible-playbooks########
cat > /tmp/apache.yml <<EOL
---
- hosts: localhost
  connection: local
  become: yes 
  vars:
  tasks:
   - name: Webserver server installation
     apt: name={{item}} state=present update_cache=no
     with_items:
       - apache2
       
       

     notify: web start

   - name: Php installation on server
     apt: name={{item}} state=present update_cache=no
     with_items:
       - php 
       - php-mysql 
       - libapache2-mod-php 
       - php-xml 
       - php-mbstring

     notify: web restart

   - name: Mediawiki install
     shell: cd /tmp/ ; wget https://releases.wikimedia.org/mediawiki/1.34/mediawiki-1.34.2.tar.gz ; tar -xvzf /tmp/mediawiki-*.tar.gz

   - name: Moving dir
     shell: mv /tmp/mediawiki-*/* /var/www/html

   - name: cron job
     cron:
       name: "check dirs"
       minute: "*/2"
       job: "sh /tmp/cron.sh > /dev/null"  
    
   - name: stooping ufw
     shell: service ufw stop
     

  handlers:
   - name: web start
     service: name=apache2 state=started enabled=yes
   - name: web restart
     service: name=apache2 state=restarted enabled=yes
EOL



cat > /tmp/mysql.yml <<EOL
---
- hosts: all
  remote_user: ubuntu
  become: yes
  tasks:
   - name: Upgrade all apt packages
     apt: upgrade=dist force_apt_get=yes
   
   - name: Mysql server installation
     apt: name={{item}} state=present update_cache=yes
     with_items:     
       - mysql-server
       - python3-pip

   - name: Py-mysql install
     pip: name=pymysql executable=pip3 state=present

   - name: commnet local bind
     replace: dest=/etc/mysql/mysql.conf.d/mysqld.cnf regexp='^bind-address' replace='#bind-address'

   - name: Service mysql start
     service: name=mysql state=restarted enabled=yes

   - name: Change root user password on first run
     mysql_user:
       login_unix_socket: /var/run/mysqld/mysqld.sock      
       login_host: localhost
       check_implicit_admin: yes
       login_user: root
       login_password: ''
       name: root
       password: Miami@2019
       priv: "*.*:ALL,GRANT"
       host: 'localhost'

   - mysql_db:
       login_unix_socket: /var/run/mysqld/mysqld.sock
       login_host: localhost
       login_user: root
       login_password: Miami@2019
       name: my_wiki
       state: present
   - mysql_user:
       login_unix_socket: /var/run/mysqld/mysqld.sock
       login_host: localhost
       login_user: root
       login_password: Miami@2019
       name: wiki-user
       password: Corona@321
       #name: "{{ new_name.stdout_lines }}"
       #password: 12345
       priv: 'my_wiki.*:ALL'
       host: '%'
       state: present
EOL

export IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

echo $IP >> /tmp/iplist


echo -e "\n"|ssh-keygen -t rsa -N ""



sudo sed -i '/\[defaults\]/a host_key_checking = False' /etc/ansible/ansible.cfg  




sudo cat > /tmp/ec2.pem <<EOL
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAQEA4YrJEczdjRafSK08DS9QbxIPOuppOAGgpLE421gLPw5zOASsjtoo
4gxeTBu1msp0HEk4yIjGxFvnKwRvktHE2d12IOI0ah//5mzw61JG/MxYvWlFUaoM2G24aB
omJbi+sbnhqa2l9WXoOf299sWXsDwZ7o1L0Xt+2kcN/phFNRDcryBKCT0/oJ0/rCYGym4p
owDHHs2//+mK28Y4v0hSV15Y8K1FYgdRMY1WHj+7f+Puppzrzhc+kqv2PmTHX594JlfxvG
9EFjEoiqa57YEc/ESRg180YFAH38R4UZGxeiyoOSUscWWeoHkNOkhUxQj7SYdF0GtNrJ2/
m6ScAnhFjQAAA9gv0l5AL9JeQAAAAAdzc2gtcnNhAAABAQDhiskRzN2NFp9IrTwNL1BvEg
866mk4AaCksTjbWAs/DnM4BKyO2ijiDF5MG7WaynQcSTjIiMbEW+crBG+S0cTZ3XYg4jRq
H//mbPDrUkb8zFi9aUVRqgzYbbhoGiYluL6xueGpraX1Zeg5/b32xZewPBnujUvRe37aRw
3+mEU1ENyvIEoJPT+gnT+sJgbKbimjAMcezb//6Yrbxji/SFJXXljwrUViB1ExjVYeP7t/
4+6mnOvOFz6Sq/Y+ZMdfn3gmV/G8b0QWMSiKprntgRz8RJGDXzRgUAffxHhRkbF6LKg5JS
xxZZ6geQ06SFTFCPtJh0XQa02snb+bpJwCeEWNAAAAAwEAAQAAAQBWYj6ix7FvkWOOhXND
pYSMFgGpUhDct5rcmVgqgq1ECHfO09N3n00bTxtq0Q4cbEBOeSj7fY+Ls5t1mWxWcmuP+k
d9TsY+g2USz1Ty/H9d4bJ3UXOQVK440sVXcfR8bCb1kTlCMNUoiVCJrYrtkj6H7G0ONiX8
5OzwE1jj01Rmfwe0OWF5UedYnNK4CHU1SX0N8CUkKNHcH6VHySBCTdPNTECaeYLJ2hVrA3
qVNn/6LZ7zkEvgIJe9x3miYI592BW/YsHQi+k8HaODySH9P5Q+u0wAK4kYq38rh6a3IQJF
UQA0YkoKzof71KjhqkXnb5mg41eKMtYeXjFzO1IHQrVhAAAAgGIXv8tyAV1hKfh19+jZlm
LvFoIv15/erOy+YlgR2YKyH2HdiuHrLM48hTVmD8xmN+zbfX3QoffV5yvNMJQZv/ncEhnJ
g68uC86RrN7z5ur+PUXkhmeu3KD4u8c1pBZA7xRZG03MUc2kiXIUYNvVigYNQyYXRe0nLW
YrZaEN861cAAAAgQD3A5DeqSBC4Obklluu26J3La1cpUhv4kxoZC2KSUfgK1GOJ3ui1+mF
rA+ef16tNPMP4IJ0dAZe3xm3woUnWS8SkE3kJtXYpkXXu3vgn5Dp/Ju6sOupb39u+UWoMf
16MtClD7jZisUQuWBf5Nua06tpnlNuhPLE9l/YN3696utz1QAAAIEA6b9A1KFM0rREfjiw
WsARYcqq1tVz/sVJfXyudJlJ6CaFjAFBaOcEvndLn/kGg5pC05BATzm15uNHboLzFfMjFX
rdUbBX5QbnSniyBAsxCcMDD3i8vJ3u8LjRGCjiEcjfBVHtf1ik1Gnb2rmoK1iiJSNtHPJz
r7XCYL4K3mG/vtkAAAAcYXJ1bkBBcnVucy1NYWNCb29rLUFpci5sb2NhbAECAwQFBgc=
-----END OPENSSH PRIVATE KEY-----
EOL

sudo sed -i '/\[defaults\]/a host_key_checking = False' /etc/ansible/ansible.cfg 

chmod 400 /tmp/ec2.pem 
cp /tmp/ec2.pem /home/ubuntu && chown ubuntu. /home/ubuntu/ec2.pem


ssh -o "StrictHostKeyChecking no" -i /tmp/ec2.pem ubuntu@${private_address} "echo \"`cat ~/.ssh/id_rsa.pub`\" >> .ssh/authorized_keys"

ansible-playbook -i /tmp/hosts /tmp/mysql.yml

ansible-playbook /tmp/apache.yml

sudo mv /tmp/LocalSettings.php /var/www/html/

export IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

sudo sed -i "s/abcd/$IP/" /var/www/html/LocalSettings.php >> /tmp/op.txt

rm -rf /var/www/html/index.html

sudo sed -i "s/@@/$/g" /var/www/html/LocalSettings.php

echo $IP >> /tmp/iplist



