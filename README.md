# hyltest

## Introduction
A proof of concept VM deployment on Azure, with a Docker compose setup consisting of NGINX as a web server, Keycloak for authentication, a PostgreSQL database to support the Keycloak, and oauth2-proxy as a glue component.

## Deployment
The environment is deployed using Terraform and Ansible GitHub actions, running on GitHub runners, with a helper control VM that serves as the Ansible host. There is also a Terraform Destroy action. Parameters needed for the GitHub actions are stored as repository secrets and variables. Some permissions were deployed manually, as well as the secrets vault, and data storage in order to bootstrap Terraform. A helper script fetches secrets from Azure and rewrites the values in templates before everything is ready to run.

## Host VM
Rocky Linux 9 was chosen for its reliability and compatibility as an Enterprise Linux distro. Another option would be Ubuntu or Alpine, though I prefer the dnf package manager.

There is a Certbot on the host VM that fetches Let's Encrypt certificates in order to let us use HTTPS. An alternative would be to register certs on Azure.

Docker CE was used as the container engine for the purpose of simplicity and familiarity. Docker Compose was used as a logical choice for a small, multi-container app.

## Control VM
This machine, also running Rocky 9, is not strictly part of the assignment, but would be present in a real Ansible deployment.

## Management
Azure Bastion was used, in order not to have to expose SSH to the outside world.

## Security
NSGs were set up such that only the control VM can access the app VM via SSH, and only ports 80 and 443 on the app VM are open to the outside world. Also, firewalld is enabled on the VMs.

## Caveats:
- The Ansible inventory is "dynamically hardcoded" to the one IP (taken from Terraform) for the purpose of simplicity of this PoC.
- The domain name is registered externally.

## Possible improvements:
- The domain name could be registered on Azure.
- Certificates could and should be managed by Azure in a production system.
- The containers could be hosted natively on Azure instead of inside a VM. 
- A load balancer could be used, in combination with multiple containers for failover and load distribution.
- The database could be hosted natively on Azure, which would facilitate much easier management (backups...).
- Our own runners could be set up for GitHub actions, also hosted on Azure, to save cost and increase flexibility.
- A WAF could be set up to increase security.