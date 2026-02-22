variable "prefix" {
  description = "Name prefix for all resources (lowercase letters/numbers)."
  type        = string
  default     = "YOUR_PREFIX"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "admin_ssh_public_key" {
  description = "Your SSH public key for the VM"
  type        = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "kubernetes_version" {
  type    = string
  default = null
}