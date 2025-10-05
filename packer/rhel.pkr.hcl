// packer/rhel.pkr.hcl

packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.0.0"
    }
  }
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
  headless       = local.headless
  http_directory = "http"
  disk_size      = local.disk_size_mb

  ssh_username = var.ssh_user
  ssh_password = var.ssh_pass
  ssh_timeout  = "45m"

  boot_wait = "8s"
  boot_command = [
    "<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"
  ]

  shutdown_command = "echo '${var.ssh_pass}' | sudo -S /sbin/shutdown -h now"
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
