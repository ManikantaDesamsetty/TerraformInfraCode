variable "rg_name" {
    type        = string
    description = "naming for the resource group"
}

variable "location" {
    type         = string
    description  = "defining location for the resource group"
    default      = "eastus"
}

variable "prefix" {
    type         =  string
    description  = "defining prefix for all the resources"
}

variable "vnet_cidr_prefix" {
    type         = string
    description  = "defining vnet cidr block for the resources"
}

variable "subnet_cidr_prefix" {
    type         = string
    description  = "defining subnet block for the resources"
}

variable "vm_size" {
    type         = string
    description  = "defining virtual machine size"
}

