packer {
  required_plugins {
    proxmox = {
      version = " >= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = " >= 1.1.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "proxmox-iso" "ubuntu" {

  proxmox_url               = "https://${var.proxmox_host}:8006/api2/json"
  node                      = var.proxmox_node
  username                  = var.proxmox_user
  password                  = var.proxmox_password
  token                     = var.proxmox_token
  insecure_skip_tls_verify  = true

  vm_id                     = var.vmid
  vm_name                   = var.template_name
  template_description      = var.template_description
  os                        = var.os
  memory                    = var.memory
  cores                     = var.cores
  sockets                   = var.sockets
  qemu_agent                = true
  cloud_init                = var.enable_cloud_init
  cloud_init_storage_pool   = var.disk_pool

  scsi_controller           = "virtio-scsi-pci"
  disks {
    type                    = "scsi"
    disk_size               = var.disk_size
    storage_pool            = var.disk_pool
    format                  = "raw"
  }
  boot_iso {
    type                    = "scsi"
    iso_url                 = var.iso
    iso_checksum            = var.iso_checksum
    iso_storage_pool        = var.iso_storage_pool
    unmount                 = true
  }
  network_adapters {
    model                   = "virtio"
    bridge                  = "vmbr0"
  }

  ssh_username              = var.ssh_user
  ssh_password              = var.ssh_password
  ssh_timeout               = "30m"

  http_directory            = "${path.root}/http"
  boot_wait                 = var.boot_wait
  boot_command              = var.boot_command
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "ansible" {
    playbook_file = "${path.root}/ansible/main.yml"
    inventory_directory = pathexpand("${var.ansible_inventory}")
    ansible_env_vars = [
        "ANSIBLE_REMOTE_TMP=/tmp/ansible",
    ]
    extra_arguments = [
      "--extra-vars", "ansible_become_pass=${var.ssh_password}",
    ]
  }
}
