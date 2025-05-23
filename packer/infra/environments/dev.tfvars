environment = "dev"

vnet_packer = {
  address_space  = "10.18.4.0/25" # 64 IPs
  packer_subnet  = "10.18.4.0/28"
  bastion_subnet = "10.18.4.64/26"
}
