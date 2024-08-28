# The Basics
In this exercise we are going to create a resource group in Azure.

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
## Step 1 - Terraform

Create a file called ```terraform.tf```. This will contain the terraform block which defines your required_verion and required_providers.

Add the following into the file:

```
terraform {
  required_version = "~> 1.9.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6.2"
    }
  }
}
```

## Step 2 - Resource Group

Now we have set up the providers we need, we will now create our resource group and link our random generator to it so we get a unique but consistent
value for the life span of our resource group.

While you could easily copy and paste the code example below trying typing it out and get a feel of the VSCode extensions. Create a file called ```main.tf``` and type the following into it:

```
resource "azurerm_resource_group" "lab" {
  name     = "rg-lab-1-0"
  location = "uksouth"
}

resource "random_id" "lab" {
  keepers = {
    resource_group = "${azurerm_resource_group.lab.name}"
  }

  byte_length = 2
}
```

## Step 3 - Run Terraform

To run Terraform we will need to open the terminal so we can run it locally. To do this right click on the directory for this lab and then click "open in terminal"

### Terraform init

```
terraform init
```

This will now look at what providers we are using and download them ready for us to use. You will now see under the lab directory a new folder called ".terraform" open it up and take a look.

### Terraform Plan

Run terraform plan as shown below.

```
terraform plan
```

The plan will fail and Terraform will give an error:
```
Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: Invalid provider configuration
│ 
│ Provider "registry.terraform.io/hashicorp/azurerm" requires explicit configuration. Add a provider block to the root module and configure the provider's required arguments as described in the
│ provider documentation.
│ 
╵
╷
│ Error: Missing required argument
│ 
│   with provider["registry.terraform.io/hashicorp/azurerm"],
│   on <empty> line 0:
│   (source code not available)
│ 
│ The argument "features" is required, but no definition was found.
```

This is because we haven't configured the Terraform providers.

## Step 4 - Configure providers

Create a file called ```providers.tf``` and add the following:

```
provider "azurerm" {
  features {}
}
```

## Step 5 - Run Terraform (again)

### Terraform Plan

Run terraform plan as shown below.

```
terraform plan -out tfplan
```

The plan should be shown as 2 to add, 0 to change, 0 to destroy

### Terraform Apply

Run the terraform apply as shown below.

```
terraform apply "tfplan"
```

Confirm that terraform outputs the following:

```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

## Step 6 - Destroy

Now we need to clean up our resources. Run terraform destroy to clean up:

```
terraform destory
```

Type 'yes' at the prompt to confirm that all resources should be destroyed