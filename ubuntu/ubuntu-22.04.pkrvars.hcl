iso                  = "https://www.releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
iso_checksum         = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
iso_storage_pool     = "nas"

vmid                 = 9224
template_name        = "ubuntu-2204"
template_description = "packer generated on {{isotime `2006-01-02`}}"
os                   = "l26"
memory               = 2048
cores                = 1
sockets              = 1
disk_size            = "10G"
disk_pool            = "zfs"
disk_pool_type       = "zfspool"
enable_cloud_init    = true

boot_command = [
    "<esc>e",
    "<down><down><down><end>",
    "<bs><bs><bs><bs>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "--- <f10>"
]

ansible_inventory    = "~/.ansible/inventory"
