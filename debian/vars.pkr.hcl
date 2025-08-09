variable "proxmox_host" {
  type        = string
  description = "Proxmox FQDN host name and port"
  default     = "${env("PKR_VAR_PROXMOX_HOST")}"
  validation {
    condition     = length(var.proxmox_host) > 0
    error_message = "The PROXMOX_HOST environment variable must be set."
  }
}
variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
  default     = "${env("PKR_VAR_PROXMOX_NODE")}"
  validation {
    condition     = length(var.proxmox_node) > 0
    error_message = "The PROXMOX_NODE environment variable must be set."
  }
}
variable "proxmox_user" {
  type        = string
  description = "Proxmox user name"
  default     = "${env("PKR_VAR_PROXMOX_USER")}"
  validation {
    condition     = length(var.proxmox_user) > 0
    error_message = "The PROXMOX_USER environment variable must be set."
  }
}
variable "proxmox_password" {
  type        = string
  description = "Proxmox password"
  default     = "${env("PKR_VAR_PROXMOX_PASSWORD")}"
  sensitive   = true
}
variable "proxmox_token" {
  type        = string
  description = "Proxmox api token"
  default     = "${env("PKR_VAR_PROXMOX_TOKEN")}"
  sensitive   = true
}

variable "iso" {
  type        = string
  description = "URL to an ISO which will upload to Proxmox"
}
variable "iso_checksum" {
  type        = string
  description = "Checksum of the ISO"
}
variable "iso_storage_pool" {
  type        = string
  description = "Proxmox storage pool to upload the ISO"
  default     = "local"
}

variable "vmid" {
  type        = number
  description = "Proxmox virtual machine ID"
  default     = null
}
variable "template_name" {
  type        = string
  description = "Name of template in Proxmox"
}
variable "template_description" {
  type        = string
  description = "Proxmox notes field"
  default     = null
}
variable "os" {
  type        = string
  description = "Operating system type"
}
variable "memory" {
  type        = number
  description = "Memory in MB"
  default     = 1024
}
variable "cores" {
  type        = number
  description = "Number of CPU cores"
  default     = 1
}
variable "sockets" {
  type        = number
  description = "Number of CPU sockets"
  default     = 1
}
variable "disk_size" {
  type        = string
  description = "The size of the disk including a unit suffix"
  default     = "20GB"
}
variable "disk_pool" {
  type        = string
  description = "Name of Proxmox storage pool"
  default     = "local-lvm"
}
variable "disk_pool_type" {
  type        = string
  description = "Type of the pool"
  default     = "lvm-thin"
}
variable "enable_cloud_init" {
  type        = bool
  description = "Add Cloud init drive to disk_pool location"
  default     = false
}

variable "ssh_user" {
  type        = string
  description = "SSH user"
  default     = "${env("PKR_VAR_SSH_USER")}"
  validation {
    condition     = length(var.ssh_user) > 0
    error_message = "The SSH_USER environment variable must be set."
  }
}
variable "ssh_password" {
  type        = string
  description = "SSH password"
  default     = "${env("PKR_VAR_SSH_PASSWORD")}"
  validation {
    condition     = length(var.ssh_password) > 0
    error_message = "The SSH_PASSWORD environment variable must be set."
  }
  sensitive = true
}

variable "http_port_min" {
  type        = number
  description = "Minimum port number for the Packer HTTP server"
  default     = 8305
}
variable "http_port_max" {
  type        = number
  description = "Maximum port number for the Packer HTTP server"
  default     = 8309
}
variable "boot_wait" {
  type        = string
  description = "Seconds to wait before entering the boot command."
  default     = "6s"
}
variable "boot_command" {
  type        = list(string)
  description = "Boot command to auto install Ubuntu"
}

variable "ansible_inventory" {
  type        = string
  description = "Path to existing ansible inventory."
  default     = "/tmp"
}
