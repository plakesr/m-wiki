# Getting Started

Provided configuration is used to deploy MediaWiki Application on AWS cloud. Config will create AWS-VPC with public/private subnets for web and db. 

  ## Media Wiki

  Pre-Reqs
1. Terraform Version 12 supported
2. Ansible 2.2 or above
3. Aws configured 


## Deployment commands
```
Clone repo in your linux machine and navigate to repo directory in system. 

Run below command to start deployment. 

#sh wiki.sh
  
```

** Installation will take sometime and will genrate wiki config files in your system. 

# MediaWiki Setup
```
After complete installation you will get path of mediawiki config file on your terminal. It contians your apache ip/ mysql ip and mysql user login details. 

It helps you to complete your MediaWiki inital setup. Once done you have update your LocalSetting.php in webserver. To do this run below command for same clone directory.

# ansible-playbook -i ansible/hosts ansible/local_set.yml

```
