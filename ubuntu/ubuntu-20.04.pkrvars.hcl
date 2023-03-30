iso                  = "https://releases.ubuntu.com/20.04.5/ubuntu-20.04.5-live-server-amd64.iso"
iso_checksum         = "sha256:5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"
iso_storage_pool     = "nas"

vmid                 = 9204
template_name        = "ubuntu-2004"
template_description = "packer generated on {{isotime `2006-01-02`}}"
os                   = "l26"
memory               = 2048
cores                = 1
sockets              = 1
disk_size            = "10GB"
disk_pool            = "zfs"
disk_pool_type       = "zfspool"
enable_cloud_init    = true

boot_command = [
    "<enter><enter><f6><esc><wait>",
    "<bs><bs><bs><bs>",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "--- <enter>"
  ]

ansible_inventory    = "~/.ansible/inventory"
