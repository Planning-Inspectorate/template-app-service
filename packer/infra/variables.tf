variable "tags" {
  description = "A collection of tags to assign to taggable resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "The name of the environment in which resources will be deployed"
  type        = string
}

variable "vnet_packer" {
  description = "VNet packer configuration"
  type = object({
    address_space = string
    packer_subnet = string
  })
}
