variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "The location must be either uksouth or ukwest."
  }
  default = "uksouth"
}

variable "caf_resource_group_name" {
  description = "The name of the resource group to be created."
  type        = string
  default     = "lab-2-2"
}