resource "azurerm_resource_group" "lab" {
  name     = "rg-lab-1-1-${random_pet.lab.id}"
  location = var.location
}

resource "random_pet" "lab" {
  length    = 2
  separator = "-"
}