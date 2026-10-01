# ContainerDisk wrapper: KubeVirt pulls this OCI image and mounts /disk/*.qcow2.
# Build context must contain the qcow2 at the path given by DISK_SRC (default).
ARG DISK_SRC=ubuntu-node.qcow2
FROM scratch
COPY ${DISK_SRC} /disk/ubuntu-node.qcow2
