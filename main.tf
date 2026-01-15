# 1. Configuration du Provider Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Indispensable pour éviter le blocage avec un compte étudiant
  skip_provider_registration = true
}

# 2. Groupe de Ressources (Déménagement en Europe)
resource "azurerm_resource_group" "rg_secure" {
  name     = "rg-secure-app-audit"
  location = "swedencentral"
}

# 3. Réseau Virtuel (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-secure-app"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_secure.location
  resource_group_name = azurerm_resource_group.rg_secure.name
}

# 4. Sous-réseau Public (Frontend Web)
resource "azurerm_subnet" "subnet_public" {
  name                 = "subnet-public-web"
  resource_group_name  = azurerm_resource_group.rg_secure.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 5. Sous-réseau Privé (Backend DB - Isolé)
resource "azurerm_subnet" "subnet_private" {
  name                 = "subnet-private-db"
  resource_group_name  = azurerm_resource_group.rg_secure.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
