iso                  = "https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
iso_checksum         = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
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
