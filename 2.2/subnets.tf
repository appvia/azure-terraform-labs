resource "azurecaf_name" "subnet" {
  name          = "lab-2-0"
  resource_type = "azurerm_subnet"
  random_length = 4
}

resource "random_integer" "subnet" {
  min = 0
  max = 254
  keepers = {
    main_subnet = azurecaf_name.subnet.result
  }
}

resource "azurerm_subnet" "main" {
  name                 = azurecaf_name.subnet.result
  resource_group_name  = data.azurerm_virtual_network.main.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.${random_integer.subnet.result}.0/24"]
}