# Reading Data
In this exercise we are going to create a subnet in an existing Virtual Network. To do this we will need to use a [Data Source](https://developer.hashicorp.com/terraform/language/data-sources) to get information on the existing Virtual Network resource.

## Step 1 - Add a data source

Create a new file called ```data.tf```. We will use this file to store the Data Sources.

Add the following data source to the file:
```
data "azurerm_virtual_network" "main" {
  name                = "vnet-lab-uksouth"
  resource_group_name = "rg-lab-uksouth"
}
```

## Step 2 - Add resources

Open the ```main.tf``` file, which is empty.

Add a CAF naming resource for the subnet:
```
resource "azurecaf_name" "subnet" {
  name          = "lab-2-0"
  resource_type = "azurerm_subnet"
  random_length = 4
}
```

Add a random integer generator to pick a random subnet. NOTE: This is just to avoid a subnet clash, and should never normally be done like this!
```
resource "random_integer" "subnet" {
  min = 0
  max = 254
  keepers = {
    main_subnet = azurecaf_name.subnet.result
  }
}
```

Finally create an azurerm_subnet resource:
```
resource "azurerm_subnet" "main" {
  name                 = azurecaf_name.subnet.result
  resource_group_name  = data.azurerm_virtual_network.main.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.${random_integer.subnet.result}.0/24"]
}
```

## Step 3 - Run Terraform

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