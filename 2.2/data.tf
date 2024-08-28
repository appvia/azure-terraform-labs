data "azurerm_virtual_network" "main" {
  name                = "vnet-lab-uksouth"
  resource_group_name = "rg-lab-uksouth"
}