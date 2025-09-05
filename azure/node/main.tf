resource "random_id" "vm_suffix" {
  byte_length = 4
}

resource "random_integer" "subnet_index" {
  min = 0
  max = length(var.vcluster.nodeEnvironment.outputs["private_subnet_ids"]) - 1
}

module "virtual_machine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.14.0"

  # Core configuration
  location            = local.location
  resource_group_name = local.resource_group_name
  name                = local.vm_name
  sku_size            = local.instance_type
  zone                = null # No specific zone preference, let Azure decide

  # Network configuration
  network_interfaces = {
    network_interface_1 = {
      name = format("%s-nic", local.vm_name)
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "internal"
          private_ip_subnet_resource_id = local.private_subnet_id
          create_public_ip_address      = false
        }
      }
      network_security_groups = {
        nsg_association = {
          network_security_group_resource_id = local.security_group_id
        }
      }
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 100
  }

  # Ubuntu 22.04 LTS (widely used, battle-tested for Kubernetes)
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # User data for vCluster joining
  user_data = base64encode(local.user_data)

  managed_identities = {
    system_assigned = true
  }

  # Tags
  tags = {
    Name        = local.vm_name
    Role        = "vcluster-node"
    Environment = "vcluster"
  }
}
