iso                  = "https://www.releases.ubuntu.com/noble/ubuntu-24.04.2-live-server-amd64.iso"
iso_checksum         = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
iso_storage_pool     = "nas"

vmid                 = 9244
template_name        = "ubuntu-2404"
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
