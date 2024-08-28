resource "azurecaf_name" "rg-lab" {
  name          = var.caf_resource_group_name
  resource_type = "azurerm_resource_group"
  suffixes      = [var.location]
  random_length = 4
}

resource "azurerm_resource_group" "lab" {
  name     = azurecaf_name.rg-lab.result
  location = var.location
}