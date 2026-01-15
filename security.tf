# --- NSG PUBLIC (Frontend) ---
resource "azurerm_network_security_group" "nsg_public" {
  name                = "nsg-public-web"
  location            = "swedencentral"
  resource_group_name = "rg-secure-app-audit"

  # Règle 1 : Autoriser SSH (Pour l'admin)
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Règle 2 : Autoriser HTTP (Pour le site web)
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# --- NSG PRIVÉ (Backend) ---
resource "azurerm_network_security_group" "nsg_private" {
  name                = "nsg-private-db"
  location            = "swedencentral"
  resource_group_name = "rg-secure-app-audit"

  # Règle CRITIQUE : Seul le Subnet Public peut parler à la DB (Port 3306)
  security_rule {
    name                       = "AllowMySQLFromWeb"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.0.1.0/24" # L'adresse du Subnet Public
    destination_address_prefix = "*"
  }
  
  # Par défaut, Azure bloque le reste des accès entrants depuis Internet.
}

# --- ASSOCIATION (Attacher les règles aux sous-réseaux) ---

# Attacher NSG Public -> Subnet Public
resource "azurerm_subnet_network_security_group_association" "link_public" {
  subnet_id                 = azurerm_subnet.subnet_public.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

# Attacher NSG Privé -> Subnet Privé
resource "azurerm_subnet_network_security_group_association" "link_private" {
  subnet_id                 = azurerm_subnet.subnet_private.id
  network_security_group_id = azurerm_network_security_group.nsg_private.id
}
