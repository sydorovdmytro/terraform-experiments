terraform {
  backend "azurerm" {
    storage_account_name = "${local.vcluster_name}tfstate"
    container_name       = "tfstate"
    key                  = "node/terraform.tfstate"
    use_azuread_auth     = true
  }
}
