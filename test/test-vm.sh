#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${VM_NAME:-ubuntu25.10}"
SNAPSHOT_NAME="${SNAPSHOT_NAME:-ssh-setup}"
SSH_USER="${SSH_USER:-andreas}"
SSH_HOST="${SSH_HOST:-}"
MOUNT_PATH="${MOUNT_PATH:-/mnt/dotfiles}"
RUN_BOOTSTRAP="${RUN_BOOTSTRAP:-1}"
RUN_GUEST_TESTS="${RUN_GUEST_TESTS:-0}"
SHUTDOWN_TIMEOUT_SEC="${SHUTDOWN_TIMEOUT_SEC:-120}"
BOOT_TIMEOUT_SEC="${BOOT_TIMEOUT_SEC:-180}"
SSH_TIMEOUT_SEC="${SSH_TIMEOUT_SEC:-180}"
RETRY_INTERVAL_SEC="${RETRY_INTERVAL_SEC:-3}"

SSH_OPTIONS=(
  -F /dev/null
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o ConnectTimeout=5
)

log() {
  printf '[vm-test] %s\n' "$*"
}

fail() {
  printf '[vm-test] ERROR: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

vm_state() {
  virsh domstate "$VM_NAME" 2>/dev/null | tr -d '\r'
}

wait_for_state() {
  local wanted="$1"
  local timeout="$2"
  local waited=0

  while [ "$waited" -lt "$timeout" ]; do
    local current
    current="$(vm_state || true)"
    if [ "$current" = "$wanted" ]; then
      return 0
    fi
    sleep "$RETRY_INTERVAL_SEC"
    waited=$((waited + RETRY_INTERVAL_SEC))
  done

  return 1
}

get_vm_ip_from_lease() {
  virsh domifaddr "$VM_NAME" --source lease 2>/dev/null \
    | awk '/ipv4/ {print $4}' \
    | cut -d/ -f1 \
    | head -n1
}

wait_for_vm_ip() {
  local timeout="$1"
  local waited=0

  while [ "$waited" -lt "$timeout" ]; do
    local ip
    ip="$(get_vm_ip_from_lease || true)"
    if [ -n "${ip:-}" ]; then
      printf '%s\n' "$ip"
      return 0
    fi
    sleep "$RETRY_INTERVAL_SEC"
    waited=$((waited + RETRY_INTERVAL_SEC))
  done

  return 1
}

wait_for_ssh() {
  local host="$1"
  local timeout="$2"
  local waited=0

  while [ "$waited" -lt "$timeout" ]; do
    if ssh "${SSH_OPTIONS[@]}" "${SSH_USER}@${host}" "true" >/dev/null 2>&1; then
      return 0
    fi
    sleep "$RETRY_INTERVAL_SEC"
    waited=$((waited + RETRY_INTERVAL_SEC))
  done

  return 1
}

run_remote() {
  local host="$1"

  # shellcheck disable=SC2029
  ssh "${SSH_OPTIONS[@]}" "${SSH_USER}@${host}" \
    "bash -s -- '$MOUNT_PATH' '$RUN_BOOTSTRAP' '$RUN_GUEST_TESTS'" <<'EOF'
set -euo pipefail

MOUNT_PATH="$1"
RUN_BOOTSTRAP="$2"
RUN_GUEST_TESTS="$3"

if [ ! -d "$MOUNT_PATH" ]; then
  echo "Mount path does not exist in guest: $MOUNT_PATH" >&2
  exit 1
fi

if command -v mountpoint >/dev/null 2>&1; then
  if ! mountpoint -q "$MOUNT_PATH"; then
    echo "Path exists but is not a mounted filesystem: $MOUNT_PATH" >&2
    exit 1
  fi
fi

mkdir -p "$HOME/git"
ln -sfn "$MOUNT_PATH" "$HOME/git/dotfiles"

cd "$HOME/git/dotfiles"

if [ "$RUN_BOOTSTRAP" = "1" ]; then
  sudo ./bootstrap/run.sh
fi

if [ "$RUN_GUEST_TESTS" = "1" ]; then
  ./test/test-dotfiles.sh
fi
EOF
}

main() {
  require_cmd virsh
  require_cmd ssh
  require_cmd awk
  require_cmd cut

  virsh dominfo "$VM_NAME" >/dev/null 2>&1 || fail "VM not found: $VM_NAME"
  virsh snapshot-info --domain "$VM_NAME" "$SNAPSHOT_NAME" >/dev/null 2>&1 \
    || fail "Snapshot '$SNAPSHOT_NAME' not found for VM '$VM_NAME'"

  local state
  state="$(vm_state || true)"
  if [ "$state" != "shut off" ]; then
    log "Shutting down VM '$VM_NAME' (current state: $state)"
    virsh shutdown "$VM_NAME" >/dev/null 2>&1 || true
    wait_for_state "shut off" "$SHUTDOWN_TIMEOUT_SEC" \
      || fail "Timed out waiting for VM to shut down"
  fi

  log "Reverting snapshot '$SNAPSHOT_NAME'"
  virsh snapshot-revert "$VM_NAME" "$SNAPSHOT_NAME" --force >/dev/null

  state="$(vm_state || true)"
  if [ "$state" = "running" ]; then
    log "VM '$VM_NAME' already running after snapshot revert"
  else
    log "Starting VM '$VM_NAME'"
    virsh start "$VM_NAME" >/dev/null
  fi

  local host="$SSH_HOST"
  if [ -z "$host" ]; then
    log "Resolving guest IP via libvirt DHCP lease"
    host="$(wait_for_vm_ip "$BOOT_TIMEOUT_SEC")" \
      || fail "Timed out resolving guest IP; set SSH_HOST explicitly if needed"
  fi
  log "Guest host: $host"

  log "Waiting for SSH"
  wait_for_ssh "$host" "$SSH_TIMEOUT_SEC" \
    || fail "Timed out waiting for SSH at ${SSH_USER}@${host}"

  log "Running guest bootstrap workflow"
  run_remote "$host"

  log "VM workflow completed successfully"
}

main "$@"
