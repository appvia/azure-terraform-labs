# Advanced Module
In this exercise we are going to create a more advanced module to create a secure Linux VM.

## Step 1 - Create the module

Create a new directory called ```modules``` and another subdirectory called ```linuxvm```.

Create a new file called ```outputs.tf``` in the ```linuxvm``` directory.

Create a new file called ```terraform.tf``` in the ```linuxvm``` directory and add the following content:
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
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
  }
}
```

## Step 2 - Add parameters

Create a new file called ```variables.tf``` in the ```linuxvm``` directory, and add the following content:
```
variable "location" {
  type        = string
  description = "The Azure Region in which all resources will be created."
}

variable "tags" {
  type        = map(string)
  description = "Set tags to apply to the resources"
  default     = {}
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "caf_name" {
  type        = string
  description = "Name to supply to azurecaf_name."
}

variable "vm_subnet_id" {
  type        = string
  description = "value of the subnet name for vm"
}

variable "vm_username" {
  type        = string
  description = "Admin username for the VM."
}

variable "vm_size" {
  type        = string
  description = "Size of the VM."
  default     = "Standard_B1ms"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the VM."
  default     = "1"
}

variable "source_image_id" {
  type        = string
  description = "The source image ID."
  default     = null
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "The source image reference."
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "secure_boot_enabled" {
  type        = bool
  description = "Enable secure boot for the VM."
  default     = true
}

```

## Step 3 - Add module resources

Create a new file in the ```linuxvm``` directory called ```main.tf```. 

First we are going to use the azurecaf module to generate names for our resources:
```
resource "azurecaf_name" "names" {
  name = var.caf_name
  resource_types = [
    "azurerm_linux_virtual_machine",
    "azurerm_network_interface",
    "azurerm_disk_encryption_set",
    "azurerm_network_security_group"
  ]
  suffixes      = [var.location]
  random_length = 4
  clean_input   = true
}
```

Next we'll create a NIC for the VM:
```
resource "azurerm_network_interface" "vm" {
  name                = azurecaf_name.names.results["azurerm_network_interface"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
```

Then we'll create a Network Security Group and associate it with the NIC:
```
resource "azurerm_network_security_group" "vm" {
  name                = azurecaf_name.names.results["azurerm_network_security_group"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}
```

Add the following to generate a private key for the VM:
```
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

Finally, we create the Virtual Machine itself:
```
resource "azurerm_linux_virtual_machine" "vm" {
  #checkov:skip=CKV_AZURE_50:AAD Login VM extension required
  #checkov:skip=CKV_AZURE_178:Ensure Linux VM enables SSH with keys for secure communication 
  name                       = azurecaf_name.names.results["azurerm_linux_virtual_machine"]
  resource_group_name        = var.resource_group_name
  location                   = var.location
  size                       = var.vm_size
  admin_username             = var.vm_username
  provision_vm_agent         = true
  allow_extension_operations = true
  secure_boot_enabled        = var.secure_boot_enabled
  vtpm_enabled               = var.secure_boot_enabled
  patch_assessment_mode      = "AutomaticByPlatform"

  admin_ssh_key {
    username   = var.vm_username
    public_key = tls_private_key.this.public_key_openssh
  }

  zone = var.availability_zone

  tags = var.tags

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  source_image_id = var.source_image_id

  boot_diagnostics {
    storage_account_uri = null
  }
}
```

## Step 4 - Use the module

In the ``main.tf`` in the 2.2 directory, add the following code:

```
module "vm" {
  source   = "./modules/linuxvm"
  location = var.location

  resource_group_name = azurerm_resource_group.lab.name
  vm_subnet_id        = azurerm_subnet.main.id
  vm_username         = "azureuser"
  caf_name            = "lab-2-2"
  tags = {
    environment = "lab"
  } 
}
```

## Step 5 - Run Terraform

### Terraform Plan

Run terraform plan:

```
terraform plan -out tfplan
```

The plan should be shown as 11 to add, 0 to change, 0 to destroy. 

### Terraform Apply

Run the terraform apply as shown below, confirming to approve the apply.

```
terraform apply "tfplan"
```

Confirm that terraform outputs the following:

```
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.
```

## Step 6 - Destroy

We need to clean up our resources. Run terraform destroy to clean up:

```
terraform destory
```

Type 'yes' at the prompt to confirm that all resources should be destroyed