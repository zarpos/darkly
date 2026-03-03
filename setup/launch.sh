#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Darkly – BornToSec Web Security Challenge
#  Usage:
#    bash launch.sh          → crea y arranca la VM
#    bash launch.sh stop     → apaga la VM
#    bash launch.sh destroy  → elimina la VM completamente
# ─────────────────────────────────────────────────────────────

VM_NAME="Darkly_BornToSec"
RAM=2048
CPUS=2
HOST_NET="vboxnet0"
HOST_NET_IP="172.16.60.1"
HOST_NET_MASK="255.255.255.0"
VM_IP="172.16.60.128"

# Detectar la ISO automáticamente en la carpeta del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_PATH="$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.iso" | head -n 1)"

# ── Colores ───────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✔]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✘]${NC} $*"; exit 1; }

command -v VBoxManage &>/dev/null || error "VBoxManage no encontrado. Instala VirtualBox primero."

# ── Stop ─────────────────────────────────────────────────────
stop_vm() {
  if VBoxManage list runningvms | grep -q "\"$VM_NAME\""; then
    warn "Apagando $VM_NAME..."
    VBoxManage controlvm "$VM_NAME" acpipowerbutton 2>/dev/null || \
      VBoxManage controlvm "$VM_NAME" poweroff
    info "VM apagada."
  else
    warn "La VM '$VM_NAME' no está corriendo."
  fi
}

# ── Destroy ───────────────────────────────────────────────────
destroy_vm() {
  stop_vm 2>/dev/null || true
  if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    warn "Eliminando VM '$VM_NAME'..."
    VBoxManage unregistervm "$VM_NAME" --delete
    info "VM eliminada."
  else
    warn "No existe ninguna VM llamada '$VM_NAME'."
  fi
}

# ── Start ─────────────────────────────────────────────────────
start_vm() {
  [[ -n "$ISO_PATH" ]] || error "No se encontró ningún .iso en $SCRIPT_DIR"
  info "ISO detectada: $ISO_PATH"

  # Si ya existe la VM, simplemente arrancarla
  if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    warn "La VM '$VM_NAME' ya existe — arrancando..."
    VBoxManage startvm "$VM_NAME" --type gui
    info "VM arrancada → http://$VM_IP"
    return
  fi

  info "Creando VM: $VM_NAME (RAM: ${RAM}MB, CPUs: $CPUS)"

  VBoxManage createvm --name "$VM_NAME" --ostype "Debian" --register

  VBoxManage modifyvm "$VM_NAME" \
    --memory "$RAM" \
    --cpus "$CPUS" \
    --boot1 dvd --boot2 none --boot3 none --boot4 none \
    --usb off \
    --audio none

  # Controlador IDE + ISO como DVD
  VBoxManage storagectl "$VM_NAME" \
    --name "IDE Controller" --add ide --controller PIIX4

  VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE Controller" \
    --port 0 --device 0 \
    --type dvddrive \
    --medium "$ISO_PATH"

  # Red host-only
  if ! VBoxManage list hostonlyifs | grep -q "^Name: *${HOST_NET}$"; then
    info "Creando interfaz host-only $HOST_NET..."
    VBoxManage hostonlyif create
  fi

  VBoxManage hostonlyif ipconfig "$HOST_NET" \
    --ip "$HOST_NET_IP" --netmask "$HOST_NET_MASK"

  VBoxManage modifyvm "$VM_NAME" \
    --nic1 hostonly --hostonlyadapter1 "$HOST_NET"

  info "Arrancando VM (se abrirá una ventana)..."
  VBoxManage startvm "$VM_NAME" --type gui

  echo
  echo -e "${GREEN}✔ Darkly VM corriendo!${NC}"
  echo -e "  Abre tu navegador: http://$VM_IP"
  echo
  echo -e "  Parar:   bash launch.sh stop"
  echo -e "  Borrar:  bash launch.sh destroy"
}

# ── Entry point ───────────────────────────────────────────────
case "${1:-}" in
  stop)    stop_vm    ;;
  destroy) destroy_vm ;;
  *)       start_vm   ;;
esac
