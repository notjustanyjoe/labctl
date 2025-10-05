packer {
  required_plugins {
    virtualbox = { source = "github.com/hashicorp/virtualbox", version = ">= 1.0.0" }
  }
}

variable "os_version"   { type = string, default = "9" } # set to "8" for RHEL 8
variable "iso_path"     { type = string, default = "iso/rhel-9.4-x86_64-dvd.iso" }
variable "iso_checksum" { type = string, default = "sha256:CHANGE_ME" }
variable "ssh_user"     { type = string, default = "vagrant" }
variable "ssh_pass"     { type = string, default = "vagrant" }

source "virtualbox-iso" "rhel" {
  iso_url         = var.iso_path
  iso_checksum    = var.iso_checksum
  guest_os_type   = "RedHat_64"
  headless        = true
  http_directory  = "http"
  disk_size       = 15360

  ssh_username    = var.ssh_user
  ssh_password    = var.ssh_pass
  ssh_timeout     = "45m"

  boot_wait       = "8s"
  boot_command    = ["<tab> text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"]
  shutdown_command= "echo '${var.ssh_pass}' | sudo -S /sbin/shutdown -h now"
}

build {
  sources = ["source.virtualbox-iso.rhel"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_pass}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script = "scripts/prepare.sh"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_pass}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script = "scripts/cleanup.sh"
  }

  post-processor "vagrant" {
    output = "builds/virtualbox-rhel${var.os_version}.box"
  }
}
