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
** After executing above commands, you must wait for the Ansible jobs to execute. IT will take 10-15 mins to complete the execution. MediaWiki will run on PUBLIC-IP of your WEB instance.
