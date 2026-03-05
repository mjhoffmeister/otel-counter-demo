output "AZURE_FUNCTION_APP_NAME" {
  value = azurerm_function_app_flex_consumption.func.name
}

output "AZURE_FUNCTION_APP_URL" {
  value = "https://${azurerm_function_app_flex_consumption.func.default_hostname}"
}

output "APPLICATIONINSIGHTS_CONNECTION_STRING" {
  value     = azurerm_application_insights.ai.connection_string
  sensitive = true
}

output "AZURE_RESOURCE_GROUP_NAME" {
  value = azurerm_resource_group.rg.name
}

output "AZURE_LOG_ANALYTICS_WORKSPACE_NAME" {
  value = azurerm_log_analytics_workspace.law.name
}
