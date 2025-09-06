terraform {
  backend "azurerm" {
    storage_account_name = "${local.vcluster_name}tfstate"
    container_name       = "tfstate"
    key                  = "environment/terraform.tfstate"
    use_azuread_auth     = true
  }
}
