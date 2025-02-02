### providers ###
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "az-east-rg"
    storage_account_name = "tfresdev"
    container_name       = "state"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

### rgs ###

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

### img reg ###

resource "azurerm_container_registry" "ACR_sbx" {
  name                = "${var.prefix}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

### Networking ###

resource "azurerm_virtual_network" "k8s_vnet" {
  name                = "${var.prefix}-k8s-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_public_ip" "k8s_fwpublic_ip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  tags = {
    environment = var.prefix
  }
}

resource "azurerm_subnet" "k8s_subnet" {
  name                 = "${var.prefix}-k8ssnet"
  virtual_network_name = azurerm_virtual_network.k8s_vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_route_table" "k8s_rt" {
  name                          = "${var.prefix}-k8srt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = true

  route {
    name                   = "${var.prefix}fwrn"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.fwprivate_ip
  }
}

resource "azurerm_subnet_route_table_association" "k8s_rt_subnet_rel" {
  subnet_id      = azurerm_subnet.k8s_subnet.id
  route_table_id = azurerm_route_table.k8s_rt.id
}

### sec ###

resource "azurerm_network_security_group" "k8s_nsg" {
  name                = "${var.prefix}-k8s-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "allow-https"
  priority                    = 127
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.k8s_nsg.name
}

### k8s ###

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.prefix}-k8scluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_DS3_v2"
    vnet_subnet_id = azurerm_subnet.k8s_subnet.id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
  }

  identity {
    type = "SystemAssigned"
  }
}
