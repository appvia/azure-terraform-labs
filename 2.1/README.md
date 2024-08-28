# Simple Module
In this exercise we are going to move the subnet resources into their own module to create a very simple reusable module.

## Step 1 - Create the module

Create a new directory called ```modules``` and another subdirectory called ```subnet```.

Create a new file called ```outputs.tf``` in the ```subnet``` directory.

Create a new file called ```terraform.tf``` in the ```subnet``` directory and add the following content:
```
terraform {
  required_version = ">= 1.3.1"
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">= 1.2.26"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}
```

## Step 2 - Add parameters

Create a new file called ```variables.tf``` in the ```subnet``` directory, and add the following content:
```
variable "caf_subnet_name" {
  description = "The name of the subnet to be created."
  type        = string
  default     = "subnet-main"
}

variable "subnet_address_prefix" {
  description = "The address prefix for the subnet."
  type        = string
}

variable "vnet_resource_group_name" {
  description = "The name of the resource group containing the virtual network."
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string 
}
```

## Step 3 - Add module resources

Create a new file in the ```subnet``` directory called ```main.tf```. We are going to use the azurecaf module to generate a name and a azurerm_subnet.

The contents should look like the following:
```
resource "azurecaf_name" "subnet" {
  name          = var.caf_subnet_name
  resource_type = "azurerm_subnet"
  random_length = 4
}

resource "azurerm_subnet" "main" {
  name                 = azurecaf_name.subnet.result
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.subnet_address_prefix]
}
```

## Step 4 - Use the module

In the ``main.tf`` in the 2.1 directory, add the following code:

```
module "subnet" {
    source = "./modules/subnet"
    caf_subnet_name = "subnet-main"
    subnet_address_prefix = "10.0.${random_integer.subnet.result}.0/24"
    vnet_resource_group_name = data.azurerm_virtual_network.main.resource_group_name
    vnet_name = data.azurerm_virtual_network.main.name
}
```

## Step 5 - Run Terraform

### Terraform Plan

Run terraform plan again with a valid value to location provided on the command line:

```
terraform plan -out tfplan
```

The plan should be shown as 3 to add, 0 to change, 0 to destroy. 

### Terraform Apply

Run the terraform apply as shown below, confirming to approve the apply.

```
terraform apply "tfplan"
```

Confirm that terraform outputs the following:

```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

## Step 6 - Destroy

We need to clean up our resources. Run terraform destroy to clean up:

```
terraform destory
```

Type 'yes' at the prompt to confirm that all resources should be destroyed