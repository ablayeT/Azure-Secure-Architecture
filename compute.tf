# --- VM PUBLIC (WEB) ---
# IP Publique pour pouvoir se connecter
resource "azurerm_public_ip" "pip_web" {
  name                = "pip-web"
  location            = "swedencentral"
  resource_group_name = "rg-secure-app-audit"
  allocation_method   = "Static" # IP Fixe
  sku                 = "Standard"
}

# Carte Réseau (NIC)
resource "azurerm_network_interface" "nic_web" {
  name                = "nic-web"
  location            = "swedencentral"
  resource_group_name = "rg-secure-app-audit"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_web.id # On attache l'IP publique ici
  }
}

# La Machine Virtuelle
resource "azurerm_linux_virtual_machine" "vm_web" {
  name                = "vm-web-frontend"
  resource_group_name = "rg-secure-app-audit"
  location            = "swedencentral"
  size                = "Standard_B1s" # La moins chère
  admin_username      = "adminuser"
  custom_data         = filebase64("install_nginx.sh")
  network_interface_ids = [
    azurerm_network_interface.nic_web.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub") # Ma clé SSH locale
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# --- VM PRIVÉE (DB) ---
# Pas d'IP Publique ici ! Elle est cachée.
resource "azurerm_network_interface" "nic_db" {
  name                = "nic-db"
  location            = "swedencentral"
  resource_group_name = "rg-secure-app-audit"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_private.id # Subnet Privé
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm_db" {
  name                = "vm-db-backend"
  resource_group_name = "rg-secure-app-audit"
  location            = "swedencentral"
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_db.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# --- OUTPUTS (Pour récupérer l'IP facilement) ---
output "public_ip_web" {
  value = azurerm_public_ip.pip_web.ip_address
}

output "private_ip_db" {
  value = azurerm_network_interface.nic_db.private_ip_address
}
