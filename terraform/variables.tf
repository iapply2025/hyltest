variable "prefix" {
  description = "Name prefix for resources"
  type        = string
  default     = "kc-demo"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "control_vm_size" {
  description = "Size for the control (Ansible) VM"
  type        = string
  default     = "Standard_B1ms"
}

variable "admin_username" {
  description = "Admin user on the VM"
  type        = string
  default     = "rocky"
}

variable "ssh_public_key" {
  description = "SSH public key for the admin user"
  type        = string
}
