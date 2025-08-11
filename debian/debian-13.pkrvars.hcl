iso                  = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.0.0-amd64-netinst.iso"
iso_checksum         = "sha512:069d47e9013cb1d651d30540fe8ef6765e5d60c8a14c8854dfb82e50bbb171255d2e02517024a392e46255dcdd18774f5cbd7e9f3a47aa1b489189475de62675"
iso_storage_pool     = "nas"

vmid                 = 9400
template_name        = "debian-13"
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
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    "<enter>"
]

ansible_inventory    = "~/.ansible/inventory"
