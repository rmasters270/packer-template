# Packer Proxmox Templates

Create a Proxmox templates using Packer

## Supported Builds

- Debian 12
- Debian 13
- Ubuntu 20.04
- Ubuntu 22.04
- Ubuntu 24.04

## Build Image Template with Script

### Validate Ubuntu 20.04

```shell
./packer.sh --os ubuntu -os-version '20.04'
```

### Build Ubuntu 20.04

```shell
./packer.sh build --os ubuntu -os-version '20.04'
```

### Build Ubuntu 20.04 and create log, force, and debug

```shell
./packer.sh build --os ubuntu --os-version '20.04' --log ./ubuntu.log --build-options '-force -debug'
```

## Encrypted Secrets

The script, `packer.sh` uses SOPS and AGE to decrypt secrets.  To use this functionality the following items need to be configured.

1. Install SOPS
2. Install AGE
3. Generate an AGE key
4. Set `SOPS_AGE_KEY_FILE` environment variable equal to the AGE key path.

The script will look for secrets in `proxmox.secrets.env`, `${OS}.secrets.env` `${OS}-${OS_VERSION}.secrets.env`.

## Variable substitution

The `packer.sh` script exports secret variables and uses `envsubst` to replace variables in those files.  Files with the file extension `.envsubst` will have variables, (e.g. `${VARIABLE_NAME}`) replaced.  The new files will include the original file name without the `.envsubst` file extension.

Variables can be defined in multiple `env` files, but the OS version (e.g. `${OS}-${OS_VERSION}.secrets.env`) will supercede entries also defined in OS secrets.

### Variables

| variable             | default                     | required | description                                      |
| -------------------- | --------------------------- | -------- | ------------------------------------------------ |
| proxmox_host         | ${PKR_VAR_PROXMOX_HOST}     | Yes      | Proxmox FQDN host name and port                  |
| proxmox_node         | ${PKR_VAR_PROXMOX_NODE}     | Yes      | Proxmox node name                                |
| proxmox_user         | ${PKR_VAR_PROXMOX_USER}     | Yes      | Proxmox user name                                |
| proxmox_password     | ${PKR_VAR_PROXMOX_PASSWORD} | No       | Proxmox password                                 |
| proxmox_token        | ${PKR_VAR_PROXMOX_TOKEN}    | No       | Proxmox api token                                |
| iso                  |                             | Yes      | URL to an ISO which will upload to Proxmox       |
| iso_checksum         |                             | Yes      | Checksum of the ISO                              |
| iso_storage_pool     | local                       | No       | Proxmox storage pool to upload the ISO           |
| vmid                 |                             | No       | Proxmox virtual machine ID                       |
| template_name        |                             | Yes      | Name of template in Proxmox                      |
| template_description |                             | No       | Proxmox notes field                              |
| os                   |                             | Yes      | Operating system type                            |
| memory               | 1024                        | No       | Memory in MB                                     |
| cores                | 1                           | No       | Number of CPU cores                              |
| sockets              | 1                           | No       | Number of CPU sockets                            |
| disk_size            | 20GB                        | No       | The size of the disk including a unit suffix     |
| disk_pool            | local-lvm                   | No       | Name of Proxmox storage pool                     |
| disk_pool_type       | lvm-thin                    | No       | Type of the pool                                 |
| enable_cloud_init    | False                       | No       | Add Cloud init drive to disk_pool location       |
| ssh_user             | ${PKR_VAR_SSH_USER}         | No       | SSH user                                         |
| ssh_password         | ${PKR_VAR_SSH_PASSWORD}     | Yes      | SSH password                                     |
| http_port_min        | 8305                        | No       | Minimum port number for the Packer HTTP server   |
| http_port_max        | 8309                        | No       | Maximum port number for the Packer HTTP server   |
| boot_wait            | 6s                          | No       | Seconds to wait before entering the boot command |
| boot_command         |                             | Yes      | Boot command to auto install Ubuntu              |
| ansible_inventory    |                             | No       | Path to existing Ansible inventory               |

#### Additional Variable Information

`proxmox_user`: Proxmox user account must be in the format `user`@`domain`!`token_name`.  If a Proxmox password is used omit the `token_name`.

`proxmox_password`: Either the password or the token must be provided.  The token is preferred.  If both are given the token will take precedence. If a password is given the token name may be omitted from the `proxmox_user`.

`proxmox_token`: Either the token or the password must be provided.  The token is preferred.  If both are given the token will take precedence. If a token is given the token name must be included in the `proxmox_user`.

`ssh_password`: If `PKR_VAR_SSH_PASSWORD` is defined packer.sh will use python to generate a hashed password and store it in `SSH_PASSWORD_HASH`.

`boot_wait`: Depending on your hardware, adjust the boot wait time.  Too short or too long, and the automated boot sequence will not execute.

## Other Configuration

### Ansible Provisioner

The Packer build uses the Ansible Provisioner to accomplish the following tasks:

- Update and clean up installed apt packages.
- Remove the machine-id.
- Update netplan for use with Cloud Init.
- Prepare and Cloud Init.

### Cloud Init

The template, `99_pve.cfg.j2`, defines Cloud Init configuration. The file accomplishes the following:

- Set time zone.
- Allow cloud init to define the default user.
- Upgrade installed packages.
- Grow the partition to fit the disk size assigned in Cloud Init.
- Apply netplan.
- Create a birth certificate when child machines are created.
- Update the hostname file.
