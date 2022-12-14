# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

#### Build VMImage using Packer
In order for the server.json file to run with packer, you will need to add environment variables (env var) first. These variables values are your Azure Service Principle.

If you are on Windows, you can either add the env var via using UI or if you opt to run the commands, please use the following

```cmd
setx ARM_CLIENT_ID <your-client-id>
setx ARM_CLIENT_SECRET <your-client-secret>
setx ARM_SUBSCRIPTION_ID <your-az-subscription-id>
```

However, you are on Linux or Mac, please use the following commands

```bash
export ARM_CLIENT_ID=<your-client-id>
export ARM_CLIENT_SECRET=<your-client-secret>
export ARM_SUBSCRIPTION_ID=<your-az-subscription-id>
```
Note that we often set env var in uppercase. 
---
After done with setting the env, you can continue build your image (server.json) with the following command: 

```bash
packer build server.json
```
or you can go to this doc for further information (https://learn.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer)

Note that the build duration would take a while, after done with the build, remember to save the packer image ID for later user of resource creation in Terraform.

#### Create Resources with Terraform
You will be able to create resources with Terraform templates onto Azure. However, you will need to provide the Azure tenant id. Please use either `setx` or `export` as guided above.

You will need to be **in the terraform folder** to able to run terraform apply by using this command

```
terraform apply -var="required_tag={<please put in a tag>}" -var="image_id=<your packer image id>" -var="vm_num=<enter a number of wanted VMs>"
```

Note that this template is just my own guiding
### Output
You can check and monitor the output on Azure Portal. If there are any error, then please advise me to fix it. Good luck!
