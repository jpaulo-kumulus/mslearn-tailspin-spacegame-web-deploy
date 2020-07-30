# Configure the Azure provider
provider "azurerm" {
  version         = "~> 1.32"
  subscription_id = var.subscription_id
}

# Create a new resource group
resource "azurerm_resource_group" "rg" {
  name     = "tailspin-space-game-rg"
  location = "westus2"
}

# This creates the Dev/Test plan that the service use
resource "azurerm_app_service_plan" "test" {
  name                = "tailspin-space-game-test-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "app"
  sku {
    tier = "Basic"
    size = "B1"
  }
}

# This creates the Prod plan that the service use
resource "azurerm_app_service_plan" "prod" {
  name                = "tailspin-space-game-prod-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "app"
  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

#Creating the WebApps
resource "azurerm_app_service" "dev" {
  name                = "tailspin-space-game-web-dev-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.test.id
  resource_group_name = azurerm_resource_group.rg.name

}

resource "azurerm_app_service" "test" {
  name                = "tailspin-space-game-web-test-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.test.id
  resource_group_name = azurerm_resource_group.rg.name

}

resource "azurerm_app_service" "staging" {
  name                = "tailspin-space-game-web-staging-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.prod.id
  resource_group_name = azurerm_resource_group.rg.name

}

# Creating the swap slot in the Staging WebApp
resource "azurerm_app_service_slot" "swap" {
  name                = "swap"
  app_service_name    = azurerm_app_service.staging.name
  location            = azurerm_app_service.staging.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service.staging.app_service_plan_id
}
