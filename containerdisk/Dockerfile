# ContainerDisk for KubeVirt: single regular file under /disk/.
# qemu user (107) owns the disk; do not COPY a directory tree here.
FROM scratch
ARG DISK_SRC=ubuntu-node.qcow2
# Redeclare ARG after FROM so build-arg is visible to COPY.
ARG DISK_SRC
COPY --chown=107:107 ${DISK_SRC} /disk/disk.img
