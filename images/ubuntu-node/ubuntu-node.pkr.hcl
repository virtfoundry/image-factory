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
  default = "1.34.12"
}

variable "ubuntu_version" {
  type    = string
  default = "24.04"
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

locals {
  vm_name = "vf-ubuntu-node-${var.kubernetes_version}"
}

source "qemu" "ubuntu" {
  iso_url      = var.ubuntu_img_url
  # SHA256SUMS on cloud-images; packer resolves the matching filename.
  iso_checksum = "file:https://cloud-images.ubuntu.com/releases/24.04/release/SHA256SUMS"
  # Cloud images are disks, not install ISOs.
  disk_image = true

  output_directory = var.output_directory
  vm_name          = "${local.vm_name}.qcow2"
  format           = "qcow2"
  disk_size        = var.disk_size

  accelerator = "kvm"
  memory      = 4096
  cpus        = 2
  headless    = true

  ssh_username = "ubuntu"
  # Matches images/ubuntu-node/cloud-init/user-data (build-time only).
  ssh_password = "virtfoundry-build"
  ssh_timeout  = "45m"
  cd_files = [
    "${path.root}/cloud-init/user-data",
    "${path.root}/cloud-init/meta-data",
  ]
  cd_label = "cidata"

  shutdown_command       = "echo virtfoundry-build | sudo -S shutdown -P now"
  ssh_handshake_attempts = 100
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    execute_command = "sudo -E bash '{{ .Path }}'"
    environment_vars = [
      "KUBERNETES_VERSION=${var.kubernetes_version}",
    ]
    scripts = [
      "${path.root}/scripts/install-k8s.sh",
    ]
  }

  post-processor "manifest" {
    output     = "${var.output_directory}/manifest.json"
    strip_path = true
  }
}
