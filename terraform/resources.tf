terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.35.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "rg1" {
  name     = "rg-rubicon-devops-001"
  location = "West Europe"
}

resource "azurerm_storage_account" "StorageAcc" {
  name                     = "eldin"
  resource_group_name      = "rg-rubicon-devops-001"
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "crrubicondevops001"
  resource_group_name = "rg-rubicon-devops-001"
  location            = "West Europe"
  sku                 = "Basic"
}

resource "azurerm_sql_server" "rubiserver" {
  name                         = "sql-rubicon-devops-001"
  resource_group_name          = "rg-rubicon-devops-001"
  location                     = "West Europe"
  version                      = "12.0"
  administrator_login          = "rubicon-user"
  administrator_login_password = "Babaroga1$"

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.StorageAcc.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.StorageAcc.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }
}


resource "azurerm_sql_database" "rubidb" {
  name                = "sqldb-rubicon-devops-001"
  resource_group_name = "rg-rubicon-devops-001"
  location            = "West Europe"
  server_name         = "sql-rubicon-devops-001"
}


resource "azurerm_app_service_plan" "splan" {
  name                = "plan-rubicon-devops-001"
  location            = "West Europe"
  resource_group_name = "rg-rubicon-devops-001"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "appconta" {
  name                = "app-rubicon-devops-001"
  location            = "West Europe"
  resource_group_name = "rg-rubicon-devops-001"
  app_service_plan_id = azurerm_app_service_plan.splan.id


  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "sqldb-rubicon-devops-001"
    type  = "SQLServer"
    value = "Server=tcp:sql-rubicon-devops-001.database.windows.net,1433;Initial Catalog=sqldb-rubicon-devops-001;Persist Security Info=False;User ID=rubicon-user;Password=Babaroga1$;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}







