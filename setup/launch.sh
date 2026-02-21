#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Darkly – BornToSec Web Security Challenge
#  Launch script (no Vagrant required — uses VBoxManage only)
#
#  Usage:
#    bash launch.sh          → creates and boots the VM
#    bash launch.sh stop     → shuts down the VM
#    bash launch.sh destroy  → removes the VM completely
# ─────────────────────────────────────────────────────────────

set -e

VM_NAME="Darkly_BornToSec"
VM_IP="172.16.60.128"
ISO_NAME="Darkly_i386.iso"
HOST_NET="vboxnet0"
HOST_NET_IP="172.16.60.1"
HOST_NET_MASK="255.255.255.0"

# Resolve ISO path relative to the script's own directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_PATH="$SCRIPT_DIR/$ISO_NAME"

# ── Colours ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✔]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✘]${NC} $*"; exit 1; }

# ── Helper: check VBoxManage is available ────────────────────
check_deps() {
  command -v VBoxManage &>/dev/null || \
    error "VBoxManage not found. Please install VirtualBox first."
}

# ── Stop the VM ───────────────────────────────────────────────
stop_vm() {
  if VBoxManage list runningvms | grep -q "\"$VM_NAME\""; then
    warn "Stopping $VM_NAME..."
    VBoxManage controlvm "$VM_NAME" acpipowerbutton 2>/dev/null || \
      VBoxManage controlvm "$VM_NAME" poweroff
    info "VM stopped."
  else
    warn "VM '$VM_NAME' is not running."
  fi
}

# ── Destroy the VM ────────────────────────────────────────────
destroy_vm() {
  stop_vm 2>/dev/null || true
  if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    warn "Destroying VM '$VM_NAME'..."
    VBoxManage unregistervm "$VM_NAME" --delete
    info "VM destroyed."
  else
    warn "No VM named '$VM_NAME' found."
  fi
}

# ── Create and start the VM ───────────────────────────────────
start_vm() {
  # Pre-flight: ISO must exist
  [[ -f "$ISO_PATH" ]] || \
    error "$ISO_NAME not found.\n  Expected: $ISO_PATH\n  Download it from the 42 intra and place it in this directory."

  # If a VM with this name already exists, just start it
  if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    warn "VM '$VM_NAME' already exists — starting it."
    VBoxManage startvm "$VM_NAME" --type headless 2>/dev/null || \
      VBoxManage startvm "$VM_NAME"
    info "VM started → http://$VM_IP"
    return
  fi

  info "Creating VM: $VM_NAME"

  # ── Create the VM ──────────────────────────────────────────
  VBoxManage createvm \
    --name "$VM_NAME" \
    --ostype "Debian" \
    --register

  # ── Basic settings ─────────────────────────────────────────
  VBoxManage modifyvm "$VM_NAME" \
    --memory 1024 \
    --cpus 1 \
    --boot1 dvd --boot2 none --boot3 none --boot4 none \
    --usb off \
    --audio none

  # ── Storage: IDE controller + ISO as DVD ───────────────────
  VBoxManage storagectl "$VM_NAME" \
    --name "IDE Controller" \
    --add ide \
    --controller PIIX4

  VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE Controller" \
    --port 0 --device 0 \
    --type dvddrive \
    --medium "$ISO_PATH"

  # ── Host-only network ──────────────────────────────────────
  # Create vboxnet0 in 172.16.60.0/24 if it doesn't exist
  if ! VBoxManage list hostonlyifs | grep -q "^Name: *$HOST_NET$"; then
    info "Creating host-only interface $HOST_NET..."
    VBoxManage hostonlyif create
  fi

  VBoxManage hostonlyif ipconfig "$HOST_NET" \
    --ip "$HOST_NET_IP" \
    --netmask "$HOST_NET_MASK"

  VBoxManage modifyvm "$VM_NAME" \
    --nic1 hostonly \
    --hostonlyadapter1 "$HOST_NET"

  # ── Start the VM ───────────────────────────────────────────
  info "Booting VM (a window will open)..."
  VBoxManage startvm "$VM_NAME"

  echo
  echo -e "${GREEN}✔ Darkly VM is running!${NC}"
  echo -e "  Open your browser: http://$VM_IP"
  echo
  echo -e "  Stop:    bash launch.sh stop"
  echo -e "  Destroy: bash launch.sh destroy"
}

# ── Entry point ───────────────────────────────────────────────
check_deps

case "${1:-}" in
  stop)    stop_vm    ;;
  destroy) destroy_vm ;;
  *)       start_vm   ;;
esac
