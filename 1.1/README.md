# Variables

In this exercise we are going to add a variable to allow us to supply the Azure Region where the resources will be deployed. Some files have already been created in the 1.1 directory.

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

## Step 1 - Defining the variable

You will find some files already created within the 1.1 directory.

Create a file called ```variables.tf``` to store the variables.

Add the following content into the new file:

```
variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
}
```

## Step 2 - Using the variable

Open the ```main.tf``` file and edit the azurerm_resource_group resource to use the new variable we created in Step 1 for it's location.

After you've updated the resource, it should look like this:

```
resource "azurerm_resource_group" "lab" {
  name     = "rg-lab-1-1-${random_pet.lab.id}"
  location = var.location
}
```

## Step 3 - Run Terraform

To run Terraform we will need to open the terminal so we can run it locally. To do this right click on the directory for this lab and then click "open in terminal"

### Terraform init

```
terraform init
```

### Terraform Plan

Run terraform plan as shown below.

```
terraform plan
```

You will be prompted to provide a value for var.location. Type in ```eastus``` and press enter.

Terraform will return an error similar to the following:

```
Error: Invalid value for variable
│ 
│   on variables.tf line 1:
│    1: variable "location" {
│     ├────────────────
│     │ var.location is "eastus"
│ 
│ The location must be either uksouth or ukwest.
│ 
│ This was checked by the validation rule at variables.tf:4,3-13.
```

This is because the location we provided does not pass the validation rule.

## Step 4 - Run Terraform (again)

### Terraform Plan

Run terraform plan again with a valid value to location provided on the command line:

```
terraform plan -var="location=uksouth" -out tfplan
```

The plan should be shown as 2 to add, 0 to change, 0 to destroy. Note that the location is shown in the output as ```"uksouth"``` but the name is ```(known after apply)```.

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

We need to clean up our resources. Run terraform destroy to clean up:

```
terraform destory
```

Type 'yes' at the prompt to confirm that all resources should be destroyed
