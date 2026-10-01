#!/usr/bin/env bash
# Install containerd + kubelet/kubeadm/kubectl at a pinned Kubernetes patch version.
# Runs inside the Packer guest as root.
set -euo pipefail

KUBERNETES_VERSION="${KUBERNETES_VERSION:?set KUBERNETES_VERSION e.g. 1.36.5}"
# apt packages use major.minor (e.g. 1.36)
K8S_SERIES="${KUBERNETES_VERSION%.*}"

export DEBIAN_FRONTEND=noninteractive

# cloud-init (package_update) often still holds apt when SSH first comes up.
if command -v cloud-init >/dev/null 2>&1; then
  cloud-init status --wait || true
fi
# Belt-and-suspenders: wait for apt/dpkg locks to clear.
for _ in $(seq 1 60); do
  if ! fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 \
    && ! fuser /var/lib/apt/lists/lock >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

# --- containerd ---
apt-get update -y
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
# SystemdCgroup = true (kubelet)
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable containerd
systemctl restart containerd

# --- Kubernetes apt repo (pkgs.k8s.io) ---
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_SERIES}/deb/Release.key" \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_SERIES}/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
# Pin exact patch when available; fall back to series.
if apt-cache madison kubelet | grep -q "${KUBERNETES_VERSION}-"; then
  PIN="${KUBERNETES_VERSION}-*"
else
  PIN="${K8S_SERIES}.*"
  echo "WARN: exact ${KUBERNETES_VERSION} not in apt; installing ${PIN}" >&2
fi

apt-get install -y \
  "kubelet=${PIN}" \
  "kubeadm=${PIN}" \
  "kubectl=${PIN}"
apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet

# Kernel modules / sysctl for kubeadm (workers)
cat >/etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay || true
modprobe br_netfilter || true

cat >/etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system || true

# Clear machine-id so clones get unique IDs
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id

# Remove build password auth leftovers where safe
passwd -l ubuntu || true

kubelet --version
kubeadm version -o short
kubectl version --client -o yaml | head -20

echo "install-k8s.sh done for ${KUBERNETES_VERSION}"
