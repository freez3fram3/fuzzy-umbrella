output "id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}

output "client_key" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
}

output "registry_login_server" {
  value = azurerm_container_registry.ACR_sbx.login_server
}

output "registry_username" {
  value = azurerm_container_registry.ACR_sbx.admin_username
}

output "registry_password" {
  value     = azurerm_container_registry.ACR_sbx.admin_password
  sensitive = true
}
