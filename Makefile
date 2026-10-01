# SPDX-License-Identifier: Apache-2.0
.PHONY: init build-ubuntu-node containerdisk-ubuntu-node clean

KUBERNETES_VERSION ?= 1.36.5
OUT ?= out/ubuntu-node
DISK ?= $(OUT)/vf-ubuntu-node-$(KUBERNETES_VERSION).qcow2
IMAGE ?= ghcr.io/virtfoundry/node-ubuntu:$(KUBERNETES_VERSION)

init:
	packer init images/ubuntu-node/

build-ubuntu-node: init
	rm -rf $(OUT)
	cd images/ubuntu-node && packer build \
		-var "kubernetes_version=$(KUBERNETES_VERSION)" \
		-var "output_directory=../../$(OUT)" \
		ubuntu-node.pkr.hcl

containerdisk-ubuntu-node:
	@test -f "$(DISK)" || (echo "missing $(DISK) — run make build-ubuntu-node first"; exit 1)
	cp "$(DISK)" containerdisk/ubuntu-node.qcow2
	docker build -t "$(IMAGE)" \
		-f containerdisk/Dockerfile \
		--build-arg DISK_SRC=ubuntu-node.qcow2 \
		containerdisk/
	rm -f containerdisk/ubuntu-node.qcow2
	@echo "Built $(IMAGE) (local tag only — push via CI with digest)"

clean:
	rm -rf out/ containerdisk/ubuntu-node.qcow2
