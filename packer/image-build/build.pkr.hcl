packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

source "azure-arm" "packer-image" {
  azure_tags = {
    Environment      = "Dev"
    os_type          = "Ubuntu24"
    Project          = "Template"
    CreatedBy        = "Packer"
    Node             = "22"
    Python           = "3.12"
    TerraformVersion = "${var.terraform_version}"
  }

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

build {
  name = "azure-devops-agents"

  source "source.azure-arm.packer-image" {
    managed_image_resource_group_name = var.template_resource_group_name
    managed_image_name                = "agent-ubuntu24-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

    os_type         = "Linux"
    image_publisher = "canonical"
    image_offer     = "0001-com-ubuntu-server-focal"
    image_sku       = "24_04-lts"

    location = "UK South"
    vm_size  = "Standard_DS2_v2"
  }

  # provisioner "shell" {
  #   execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E bash -e '{{ .Path }}'"
  #   script          = "${path.cwd}/config.sh"
  # }

  # provisioner "file" {
  #   source      = "config.sh"
  #   destination = "/tmp/config.sh"
  # }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E bash -e '{{ .Path }}'"
    script          = "${path.cwd}/tools.sh"
  }
}

variable "client_id" {
  description = "The ID of the service principal used to build the image"
  type        = string
}

variable "client_secret" {
  description = "The client secret of the service principal used to build the image"
  type        = string
}

variable "subscription_id" {
  description = "The ID of the subscription containing the service principal used to build the image"
  type        = string
}

variable "tenant_id" {
  description = "The ID of the tenant containing the service principal used to build the image"
  type        = string
}

variable "template_resource_group_name" {
  description = "The name of the Template resource group where the image will be created"
  type        = string
}

variable "terraform_version" {
  description = "The version of Terraform used in the build"
  type        =  string
}
