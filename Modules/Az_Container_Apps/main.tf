resource "azurerm_resource_group" "rg0" {
  name     = var.rgName
  location = var.azRegion
}

resource "azurerm_container_registry" "acr" {
  name                = var.acrName
  resource_group_name = azurerm_resource_group.rg0.name
  location            = azurerm_resource_group.rg0.location
  sku                 = var.acrSku
  admin_enabled       = true
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = ar.logAnalyticsWorkSpaceName
  resource_group_name = azurerm_resource_group.rg0.name
  location            = azurerm_resource_group.rg0.location
  sku                 = var.logAnalyticsWorkSpaceSku
  retention_in_days   = var.logAnalyticsWorkSpaceRetentionDays
}

resource "azapi_resource" "env_aca" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = var.envName
  location  = azurerm_resource_group.rg0.location
  parent_id = azurerm_resource_group.rg0.id
  #schema_validation_enabled = false
  #depends_on = [azurerm_log_analytics_workspace.law]

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.law.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.law.primary_shared_key
        }
      }
    }
  })
}