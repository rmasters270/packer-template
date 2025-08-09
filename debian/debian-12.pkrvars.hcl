iso                  = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
iso_checksum         = "sha512:0921d8b297c63ac458d8a06f87cd4c353f751eb5fe30fd0d839ca09c0833d1d9934b02ee14bbd0c0ec4f8917dde793957801ae1af3c8122cdf28dde8f3c3e0da"
iso_storage_pool     = "nas"

vmid                 = 9311
template_name        = "debian-12"
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
