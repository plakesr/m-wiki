# Getting Started

Provided configuration is used to deploy MediaWiki Application on AWS cloud. Config will create AWS-VPC with public/private subnets for web and db. 

  ## Media Wiki

  Pre-Reqs
1.  Terraform Version 12 supported
2. Aws configured 

## Deployment commands
```
# Initialise terraform using 
  terraform init
  
# Config plan to check the resources
  terraform plan
  
# Apply configuration in your env
  terraform apply -y
  
```
```
** After executing above commands, you must wait for the Ansible jobs to execute. IT will take 10-15 mins to complete the execution. MediaWiki will run on PUBLIC-IP of your WEB instance.

How to login - 

Fill media wiki details as below for mysql-

Private IP - Your Mysql instance private ip
Mysql user - wiki-user / Corona@321

Once you have completed the setup page, it will ask you to Download LocalSetting.php file. Please Download it and place it in git repo, commit your repo change and push it to github.

After pushing the changes, cron will download the php file after 2 minute and place it in MediaWiki root path. 


```