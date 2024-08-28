# CAF Naming Provider

In this exercise we are introducing the [CAF Naming Provider](https://github.com/aztfmod/terraform-provider-azurecaf), implements a set of methodologies for naming convention implementation including the default Microsoft Cloud Adoption Framework for Azure recommendations as per https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging. 

We will use the CAF module to generate a name for our resource group.

## Prerequisites

Terraform credentials should be provided as Environment Variables e.g.
```
# sh
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="12345678-0000-0000-0000-000000000000"
export ARM_TENANT_ID="10000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="20000000-0000-0000-0000-000000000000"
```
```
# PowerShell
> $env:ARM_CLIENT_ID = "00000000-0000-0000-0000-000000000000"
> $env:ARM_CLIENT_SECRET = "12345678-0000-0000-0000-000000000000"
> $env:ARM_TENANT_ID = "10000000-0000-0000-0000-000000000000"
> $env:ARM_SUBSCRIPTION_ID = "20000000-0000-0000-0000-000000000000"
```

## Step 1 - Add another variable

You will find some files already created within the 1.2 directory.

Open the ```variables.tf``` file and add an additional variable into the file:

```
variable "caf_resource_group_name" {
    description = "The name of the resource group to be created."
    type        = string
}
```

## Step 2 - Add the CAF Naming provider

Open the ```terraform.tf``` file and add an additional provider to the ```required_providers``` list as follows:

```
azurecaf = {
    source  = "aztfmod/azurecaf"
    version = ">= 1.2.23"
}
```

Open the ```providers.tf``` file and add the configuration for the azurecaf provider:

```
provider "azurecaf" {
  
}
```

## Step 3 - Using the CAF Naming provider

Open the ```main.tf``` file and add a azurecaf_name resource:
```
resource "azurecaf_name" "rg-lab" {
  name          = var.caf_resource_group_name
  resource_type = "azurerm_resource_group"
  suffixes      = [var.location]
  random_length = 4
}
```

Update the ```azurerm_resource_group``` called ```lab``` to use the new ```azurecaf_name``` output. The resource should look as follows:
```
resource "azurerm_resource_group" "lab" {
  name     = azurecaf_name.rg-lab.result
  location = var.location
}
```

## Step 4 - Run Terraform

### Terraform Plan

Run terraform plan again with a valid value to location provided on the command line:

```
terraform plan -var="caf_resource_group_name=lab-1-2" -out tfplan
```

The plan should be shown as 2 to add, 0 to change, 0 to destroy. 

### Terraform Apply

Run the terraform apply as shown below, confirming to approve the apply.

```
terraform apply "tfplan"
```

Confirm that terraform outputs the following:

```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Note the name of resource group is in the form ```rg-lab-1-2-<4 random characters>-uksouth```.

## Step 5 - Destroy

We need to clean up our resources. Run terraform destroy to clean up:

```
terraform destory
```

Type 'yes' at the prompt to confirm that all resources should be destroyed
