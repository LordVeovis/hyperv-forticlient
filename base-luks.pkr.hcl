packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
  }
}

variable "luks_pwd" {
    type        = string
    description = "Password to unlock the LUKS partition"
    default     = env("LUKS_PWD")
    sensitive   = true
}

variable "grub_pwd" {
    type        = string
    description = "Password to unlock GRUB superuser"
    default     = env("GRUB_PWD")
    sensitive   = true
}

variable "root_pwd" {
    type = string
    description = "Linux root user password"
    default     = env("ROOT_PWD")
    sensitive   = true
}

variable "forti_username" {
  type        = string
  description = "Default username for OpenFortiVPN"
  default     = env("FORTI_USER")
}

variable "forti_dns" {
  type        = string
  description = "VPN server hostname"
  default     = env("FORTI_DNS")
}

variable "vm_name" {
  type        = string
  description = "VM name"
  default     = "packer-fortress"
}

local "packer_pwd" {
  expression = "{${uuidv4()}}"
  sensitive = true
}

source "hyperv-iso" "vm" {
  iso_url                = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-virt-3.21.3-x86_64.iso"
  iso_checksum           = "sha256:f28171c35bbf623aa3cbaec4b8b29297f13095b892c1a283b15970f7eb490f2d"
  enable_dynamic_memory  = false
  enable_secure_boot     = false
  secure_boot_template   = "MicrosoftUEFICertificateAuthority"
  cpus                   = "2"
  memory                 = "256"
  disk_size              = "512"
  generation             = "2"
  switch_name            = "Default Switch"
  vm_name                = "${var.vm_name}"
  communicator           = "ssh"
  ssh_username           = "packer"
  ssh_password           = "${local.packer_pwd}"
  ssh_disable_agent_forwarding = true
  shutdown_command       = "doas poweroff"
  boot_wait              = "5s"
  boot_keygroup_interval = "20ms"
  boot_command           = [
    "root<enter><wait>",
    "setup-interfaces -ar<enter><wait2>",
    "setup-ntp chrony<enter><wait6>",
    "setup-apkrepos -1c<enter><wait>",
    "setup-sshd openssh<enter><wait>",
    "adduser packer<enter><wait>",
    "${local.packer_pwd}<enter><wait>",
    "${local.packer_pwd}<enter><wait>",
    "apk add --no-cache doas<enter><wait>",
    "echo 'permit nopass packer' >> /etc/doas.d/paker.conf<enter><wait>",
    "apk add --no-cache hvtools && rc-service hv_kvp_daemon start<enter>"
  ]
}

build {
  sources = ["sources.hyperv-iso.vm"]

  # copy files to the image
  provisioner "file" {
    sources = [
      "00_install.sh",
      "01_chroot.sh",
      "20_secureboot.sh",
      "90_debug.sh",
      "99_seal.sh",
      "nftables.nft",
      "openfortivpn.conf",
      "10-bashrc.sh",
      "05_users"
    ]
    destination = "/tmp/"
  }

  # set variables
  provisioner "shell" {
    inline = [
      "sed -i 's/__LUKS__/${var.luks_pwd}/g' /tmp/00_install.sh",
      "sed -i 's/__FORTI_DNS__/${var.forti_dns}/' /tmp/openfortivpn.conf",
      "sed -i 's/__FORTI_USERNAME__/${var.forti_username}/' /tmp/openfortivpn.conf",
      "sed -i 's/__ROOT_PWD__/${var.root_pwd}/' /tmp/01_chroot.sh",
      "doas apk add grub",
      "p=$(echo -e \"${var.grub_pwd}\n${var.grub_pwd}\" | grub-mkpasswd-pbkdf2 | grep ^PBKDF2 | awk '{print $7}')",
      "sed -i \"s/__GRUB_PWD__/$p/g\" /tmp/05_users",
      "chmod +x /tmp/00_install.sh",
    ]
  }

  # execute installation scripts
  provisioner "shell" {
    inline = [
      "doas /tmp/00_install.sh",
      "doas chroot /mnt /tmp/01_chroot.sh",
      "doas chroot /mnt /tmp/90_debug.sh",
      "doas /tmp/99_seal.sh"
    ]
  }
}