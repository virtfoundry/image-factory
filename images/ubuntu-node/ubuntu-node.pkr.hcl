# SPDX-License-Identifier: Apache-2.0
# Ubuntu LTS cloud image → VKS worker node (containerd + kubelet/kubeadm).

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.1.0"
    }
  }
}

variable "kubernetes_version" {
  type    = string
  default = "1.36.5"
}

variable "ubuntu_img_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "output_directory" {
  type    = string
  default = "../../out/ubuntu-node"
}

# kvm (local/nested) or tcg (GitHub-hosted without usable /dev/kvm)
variable "accelerator" {
  type    = string
  default = "kvm"
}

# Ubuntu OVMF paths (override on macOS/Homebrew if needed)
variable "efi_firmware_code" {
  type    = string
  default = "/usr/share/OVMF/OVMF_CODE_4M.fd"
}

variable "efi_firmware_vars" {
  type    = string
  default = "/usr/share/OVMF/OVMF_VARS_4M.fd"
}

locals {
  vm_name = "vf-ubuntu-node-${var.kubernetes_version}"
}

source "qemu" "ubuntu" {
  iso_url      = var.ubuntu_img_url
  iso_checksum = "file:https://cloud-images.ubuntu.com/releases/24.04/release/SHA256SUMS"
  disk_image   = true

  output_directory = var.output_directory
  vm_name          = "${local.vm_name}.qcow2"
  format           = "qcow2"
  disk_size        = var.disk_size
  disk_interface   = "virtio"

  accelerator         = var.accelerator
  memory              = 4096
  cpus                = 2
  headless            = true
  use_default_display = true
  # User-mode networking is default when net_bridge is unset; net_device is the NIC model.
  net_device = "virtio-net"

  # Ubuntu cloud images boot via UEFI (do not use firmware="efi" — Packer passes it as -bios).
  efi_boot          = true
  efi_firmware_code = var.efi_firmware_code
  efi_firmware_vars = var.efi_firmware_vars

  ssh_username           = "ubuntu"
  ssh_password           = "virtfoundry-build"
  ssh_timeout            = "45m"
  ssh_handshake_attempts = 100

  cd_files = [
    "${path.root}/cloud-init/user-data",
    "${path.root}/cloud-init/meta-data",
  ]
  cd_label = "cidata"

  shutdown_command = "echo virtfoundry-build | sudo -S shutdown -P now"
  shutdown_timeout = "5m"
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    # sudo -E alone still drops vars under Ubuntu env_reset; pass explicitly.
    execute_command = "sudo env KUBERNETES_VERSION='${var.kubernetes_version}' bash '{{ .Path }}'"
    scripts = [
      "${path.root}/scripts/install-k8s.sh",
    ]
  }

  post-processor "manifest" {
    output     = "${var.output_directory}/manifest.json"
    strip_path = true
  }
}
