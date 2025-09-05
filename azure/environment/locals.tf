locals {
  # Core vCluster info (using nonsensitive like AWS)
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)
  
  # Location validation (simplified from AWS validation module pattern)
  location            = nonsensitive(split(",", var.vcluster.requirements["location"])[0])
  resource_group_name = var.vcluster.requirements["resource-group"]
  
  # Dynamic networking (following AWS cidrsubnet pattern)
  vnet_cidr_block = "10.0.0.0/16"
  
  # Get availability zones from Azure regions module (like AWS)
  # The module returns a list of regions, we take the first (current region) and get its zones
  azs = length(module.regions.regions) > 0 && length(module.regions.regions[0].zones) > 0 ? module.regions.regions[0].zones : ["1"]
  
  # Calculate subnets dynamically across AZs like AWS
  public_subnets  = [for idx, az in local.azs : cidrsubnet(local.vnet_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vnet_cidr_block, 8, idx + length(local.azs))]
  
  # Resource naming with random suffix (like AWS)
  vnet_name = format("%s-%s-vnet", local.vcluster_name, random_id.vnet_suffix.hex)
}
