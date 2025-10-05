// packer/rhel.pkr.hcl

packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.0.0"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = ">= 1.0.0"
    }
  }
}

variable "boot_command" {
  type = list(string)
}

variable "firmware" {
  type    = string
  default = "efi"   # override to "bios" for RHEL 8/9
}

variable "memory" {
  type    = string
  default = "4096"  # override in var-file if you want
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "iso_path" {
  type = string
}

variable "iso_checksum" {
  type = string
}

variable "os_version" {
  type    = string
  default = "9"
}

variable "ssh_user" {
  type    = string
  default = "vagrant"
}

variable "ssh_pass" {
  type    = string
  default = "vagrant"
}

locals {
  headless     = true
  disk_size_mb = 15360
}

source "virtualbox-iso" "rhel" {
  iso_url        = var.iso_path
  iso_checksum   = var.iso_checksum
  guest_os_type  = "RedHat_64"
  headless       = true
  http_directory = "http"
  disk_size      = 15360

  ssh_username = var.ssh_user
  ssh_password = var.ssh_pass
  ssh_timeout  = "45m"

  boot_wait    = "8s"
  boot_command = var.boot_command

  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--memory", var.memory],
    ["modifyvm", "{{ .Name }}", "--cpus",   var.cpus],
    ["modifyvm", "{{ .Name }}", "--ioapic", "on"],
    ["modifyvm", "{{ .Name }}", "--rtcuseutc", "on"],
    ["modifyvm", "{{ .Name }}", "--pae", "on"],
    ["modifyvm", "{{ .Name }}", "--paravirtprovider", "kvm"],
    ["modifyvm", "{{ .Name }}", "--graphicscontroller", "vmsvga"],
    ["modifyvm", "{{ .Name }}", "--accelerate3d", "off"],
    ["modifyvm", "{{ .Name }}", "--firmware", var.firmware]
  ]
}

build {
  name    = "rhel${var.os_version}-virtualbox"
  sources = ["source.virtualbox-iso.rhel"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_pass}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "scripts/prepare.sh"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_pass}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script          = "scripts/cleanup.sh"
  }

  post-processor "vagrant" {
    keep_input_artifact = false
    output              = "builds/virtualbox-rhel${var.os_version}.box"
  }
}
