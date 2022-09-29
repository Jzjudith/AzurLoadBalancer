variable "resource_group" {
  type        = string
  description = "name of resource group"
  default     = "devlab-lb-snat-rg"
}

variable "location" {
  type        = string
  description = "name of location"
  default     = "East US2"
}

variable "availability_set" {
  type        = string
  description = "name of vailability set"
  default     = "avail-set"
}

variable "virtual_network" {
  type        = string
  description = "name of virtual network"
  default     = "lb-snat-vnet"
}

variable "subnet" {
  type        = string
  description = "name of subnet"
  default     = "lb-snat-subnet"
}

variable "public_ip" {
  type        = string
  description = "name of public ip"
  default     = "jmp-pip"
}

