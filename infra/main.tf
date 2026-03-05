resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.environment_name}"
  location = var.location
  tags     = var.tags
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "log-${var.environment_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "ai" {
  name                = "appi-${var.environment_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  tags                = var.tags
}

resource "azurerm_storage_account" "st" {
  name                     = substr("st${replace(var.environment_name, "-", "")}${random_string.suffix.result}", 0, 24)
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = false
  tags                     = var.tags
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.environment_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "FC1"
  tags                = var.tags
}

resource "azurerm_storage_container" "deploymentpackage" {
  name                  = "deploymentpackage"
  storage_account_id    = azurerm_storage_account.st.id
  container_access_type = "private"
}

locals {
  blob_storage_and_container = "${azurerm_storage_account.st.primary_blob_endpoint}deploymentpackage"
}

resource "azurerm_function_app_flex_consumption" "func" {
  name                        = "func-${var.environment_name}-${random_string.suffix.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  service_plan_id             = azurerm_service_plan.asp.id
  storage_container_type      = "blobContainer"
  storage_container_endpoint  = local.blob_storage_and_container
  storage_authentication_type = "SystemAssignedIdentity"
  runtime_name                = "dotnet-isolated"
  runtime_version             = "10.0"
  maximum_instance_count      = 2
  instance_memory_in_mb       = 2048
  tags = merge(var.tags, {
    "azd-service-name" = "func"
  })

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.ai.connection_string
  }

  app_settings = {
    "AzureWebJobsStorage"              = ""
    "AzureWebJobsStorage__accountName" = azurerm_storage_account.st.name
  }
}

resource "azurerm_role_assignment" "func_storage_blob" {
  scope                = azurerm_storage_account.st.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_function_app_flex_consumption.func.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "func_storage_queue" {
  scope                = azurerm_storage_account.st.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_function_app_flex_consumption.func.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "func_storage_table" {
  scope                = azurerm_storage_account.st.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_function_app_flex_consumption.func.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
