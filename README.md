# Project-ChungNK

test 
---
Title: Create an Automation Account and a SQL Database in Azure and create a Powershell Automation Runbook that can execute an SQL query on the database by Terraform.
---

## Step-01: Introduction
- We will build a Terraform local modules for automationaccount, automationrunbook, sqldatabase, sqlserver, keyvault. 

## Step-02: Create Module Folder Structure
- We are going to create `modules` folder and in that we are going to create a module named `automationaccount`, `automationrunbook`, `sqldatabase`, `sqlserver`, `keyvaults`.
- **Terraform Working Directory:** Project-ChungNK
- modules
- Module-1: automationaccount
1. main.tf
2. variables.tf
3. outputs.tf
4. versions.tf
- Module-2: automationrunbook
1. main.tf
2. variables.tf
3. outputs.tf
4. versions.tf
- Module-3: sqldatabase
1. main.tf
2. variables.tf
3. outputs.tf
4. versions.tf
- Module-4: sqlserver
1. main.tf
2. variables.tf
3. outputs.tf
4. versions.tf
- Module-5: keyvaults
1. main.tf
2. variables.tf
3. outputs.tf
4. versions.tf

## Step-03: Root Module: root_versions.tf
- Call Module from Terraform Work Directory
- Create Terraform Configuration in Root Module by calling the newly created module
- versions.tf
- variables.tf
- main.tf
- outputs.tf
```t
# Terraform Block
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate26637"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "< 4.0.0"
    }
}
}

# Provider Block
provider "azurerm" {
 features {}          
}
```
## Step-04: root_variables.tf
- Place holder file, if you want you can define variables.

## Step-05: root_main.tf
- Arguments for this module are going to be the variables defined in `root_variables.tf` of local module 
```t
# Call our Custom Terraform Module which we built earlier
module "automationaccount" {
  source                       = "./modules/automationaccount"  # Mandatory
  automation_account_name      = var.automation_account_name
  # Resource Group
  location                     = var.location
  resource_group_name          = var.resource_group_name
}
```

## Step-06: outputs.tf
- The output names defined in local module `outputs.tf` will be the values in this `root_outputs.tf`
```t
# Output variable definitions
output "root_automation_account_id" {
  description = "The name of the resource group"
  value       = module.automationaccount.automation_account_id
}

output "root_automation_runbook_id" {
  description = "automation runbook id"
  value       = module.automationrunbook.automation_runbook_id
}

output "root_sql_database_id" {
  description = "sql database id"
  value       = module.sqldatabase.sql_database_id
}

output "root_sql_server_id" {
  description = "sql server id"
  value       = module.sqlserver.sql_server_id
}
```
## Step-07: Login to Azure account and Run the script to create new resource group and storage account for store terraform state file before run terraform command. (Run with Bash)
* Login to Azure account:

	az login --tenant "tenant id"

	az account set --subscription "mysubscription"

* Run the script to create reourse group and storage account store terraform state

	sh createstorageaccount.sh

	Go to Azure portal and check resource group "tfstate" and check new storage account name. 
	
	Replace it to root_versions.tf  --> storage_account_name = "" # Replace name of storage account here
	
* Create Github Action Service Principal

    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription_id>" --name="GitHub-Actions"

    Save them with this information:
	
	AZURE_CLIENT_ID <>
    AZURE_CLIENT_SECRET <>
    AZURE_SUBSCRIPTION_ID <>
    AZURE_TENANT_ID <>
	
## Step-8: Modify cluster.tfvars file:
- Go to https://www.whatismyip.com/ to check our ip (to allow access to our SQL Server and SQL Database)

- Replace to here:

  start_ip_address        = "1.2.3.4" --> "Your public IP"
  end_ip_address          = "1.2.3.4" --> "Your public IP"

## Step-09: Create Ubuntu VM and add it as runner of Github Action:
Choose Linux, Architecture x64

* Follow command below to add new runner:

# Create a folder
$ mkdir actions-runner && cd actions-runner# Download the latest runner package
$ curl -o actions-runner-linux-x64-2.305.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.305.0/actions-runner-linux-x64-2.305.0.tar.gz# Optional: Validate the hash
$ echo "737bdcef6287a11672d6a5a752d70a7c96b4934de512b7eb283be6f51a563f2f  actions-runner-linux-x64-2.305.0.tar.gz" | shasum -a 256 -c# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.305.0.tar.gz
Configure
# Create the runner and start the configuration experience
$ ./config.sh --url https://github.com/nkciam/chnk --token <token># Last step, run it!
$ ./run.sh
Using your self-hosted runner

* Add Secret to repo:
- Go to Repo --> Settings --> Secrets and variables --> Actions. Add 4 Secret below:
  
      ARM_CLIENT_ID: ""
      ARM_CLIENT_SECRET: ""
      ARM_SUBSCRIPTION_ID: ""
      ARM_TENANT_ID: ""


## Step-10: Run the Github Actions


# Verify 
1. Azure Storage Resource Group created (chung-rg and tfstate).
2. Azure Storage Account created (in tfstate resource group).
3. Verify Automation Account, Runbook, SQL Server, SQL Database, KeyVault and KeyVault Secret created.
5. We need to create `SqlCredential` in Credential tab and add `SqlServer`, `Database`in Variables Tab on Automation Account because Runbook will use this information to run the job.
6. Go to SQL Server service and Open Firewall allow MyIP or CompanyIP can access to SQL Server (or we can set it on cluster.tfvars with start_ip_address and end_ip_address variable).
7. Import Module SqlServer Created by: matteot_msft (Go to automation-account-1 --> Modules --> Browse Gallery) and Run the Runbook for testing excute querry.


## Step-11: Create new table School 
- Connect to SQL Server by SQL Managerment Studio
- Go to chung-sql-database database
- Create new table name for example: School 
- Add Colums and Rows

## Step-12: Add credential and Variables for Automation Account:
- Go to Azure portal --> Automation Account --> Credentials. Add new credential name: SqlCredential. Fill admin sql server user and password infor.
- Go to variables. Add Database with value: <database name> and SqlServer with value <sqlserver name>

## Step-13: Run the Runbook:
- Go to Azure portal --> Automation Account --> automation-account-1 --> Runbooks --> automation-runbook-1 --> Start --> Check the output Tab

Document link:
Azure Automation Account: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook

Azure Runbook: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook

Azure SQL Server: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_server.html

Azure SQL Database: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_database

Azre Firewall rule for SQL Server: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sql_firewall_rule

Azure KeyVault: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret

Github Action: https://docs.github.com/en/actions
