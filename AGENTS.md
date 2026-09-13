# Dotfiles

## Overview

This project bootstraps and serves two purposes:
1. Bootstrap Ubuntu by installing essential tools
2. Configure dotfiles and development environment


## Files

File structure:

- `bootstrap/` - numbered installation scripts (00-apt-base, 01-mise, 02-repos, 03-fonts, 05-gnome, 06-tools, 08-dotfiles, 09-firefox)
- `test/` test scripts for validation in Docker
- `bin/` personal scripts (currently empty)
- `dotfiles/` managed dotfiles sources mirrored into `$HOME` via `mise`
- `mise.toml` `[dotfiles]` declarations and settings

Dotfiles convention: files under `dotfiles/` are managed via explicit `[dotfiles]` mappings in `mise.toml`.

## Usage

### Run tests manually

```bash
./test/test-docker.sh
```

### Run with Docker directly

```bash
docker build -t dotfiles-test .
docker run --rm dotfiles-test
```

Tests run inside Docker using the project `Dockerfile` and `test/test-docker.sh`.

## Test Scenarios

The Docker test runs these validations from `test/test-dotfiles.sh`:

1. **Syntax Tests** - Zsh config files
2. **Load Tests** - Zsh loads without error
3. **Startup Performance Tests** - interactive Zsh startup stays under the configured threshold
4. **Alias Tests** - common aliases exist
5. **Git Config Tests** - required Git identity/config values are set
6. **Tools Tests** - expected CLI tools are available
7. **Dotfiles State Tests** - managed dotfiles and Gradia integration are present

### Tools Managed

- `fzf`
- `zoxide`
- `opencode`
- Node.js and npm
- Java (Temurin)
- Codex
- Claude Code
- kubectl
- `Docker`
- `VS Code`
- `JetBrains Toolbox`
- `mise`

## VM Testing

Docker testing (above) can't cover GNOME desktop behavior (keybindings, default apps),
systemd services, or real (non-mocked) apt/flatpak installs. For that, use the local
libvirt VM instead:

```bash
./test/test-vm.sh
```

This resets the VM to a clean state, boots it, mounts this repo into the guest over
virtiofs at `/mnt/dotfiles` (symlinked to `~/git/dotfiles`), and runs
`./bootstrap/run.sh` over SSH as the normal user — the same thing `make install` does
on a real machine. It opens a virt-manager console window by default so you can watch
or interact with the desktop.

Useful env vars: `RUN_BOOTSTRAP=0` (skip bootstrap, just boot), `RUN_GUEST_TESTS=1`
(also run `test/test-dotfiles.sh` in-guest), `OPEN_CONSOLE=0` (skip virt-manager),
`SSH_HOST=<ip>` (skip DHCP lease lookup if it's ever unreliable).

### How the reset works (read before changing test-vm.sh)

The VM is `ubuntu25.10` (libvirt/KVM; this repo does not create it — it must already
exist). Every run of `test-vm.sh`:

1. Shuts the VM down if running.
2. Deletes `RUN_DISK` (`/var/lib/libvirt/images/ubuntu25.10.run-active`) and recreates
   it as a fresh qcow2 overlay backed by `BASE_DISK`
   (`ubuntu25.10.golden-run2`).
3. Cold-boots from that overlay.

`BASE_DISK` is a frozen image that already has an SSH key authorized, passwordless
sudo for `andreas`, the virtiofs fstab entry, and the login shell set to zsh — but
bootstrap has never been run on it. **`BASE_DISK` is never written to** by the script;
that's what makes every run start from an identical clean state. If you ever `virsh
start` the VM directly (bypassing `test-vm.sh`) and poke at it manually, you're writing
into `RUN_DISK`, which is fine and disposable — just don't do that to `BASE_DISK`.

**Why not `virsh snapshot-revert`?** The VM originally used external libvirt snapshots
with saved memory state (`mount`, `ssh-setup`, etc. — still visible in `virsh
snapshot-list ubuntu25.10` but unused/vestigial now). This is fundamentally broken
for this VM: it has a virtiofs share attached, and virtiofsd's backend state cannot be
restored from a saved memory image (fails with `Failed to load element of type
virtio-fs back-end state`). Don't reintroduce `snapshot-revert` for a running VM with
virtiofs attached — it will fail, and mid-failure it can repoint the VM's live disk
directly at the snapshot's own file, silently destroying the "clean" state you meant to
preserve (this happened once; recovering from it is how `golden-run2` came to exist).
Disk-only forking (`qemu-img create -b`, no memory state) is the only thing that works
reliably here.

**If `BASE_DISK` itself ever needs a change** (e.g. a new baseline package, a rotated
SSH key): boot a throwaway overlay off the current `BASE_DISK`, make the change over
SSH/console, shut down, then run
`virsh snapshot-create-as ubuntu25.10 <new-name> --disk-only && virsh snapshot-delete ubuntu25.10 <new-name> --metadata`.
This forks a fresh active overlay and freezes what you just changed as the new
immutable backing file (named `ubuntu25.10.<new-name>`). Update `BASE_DISK` in
`test/test-vm.sh` to point at it, and fix ownership on the new active overlay
(`chown libvirt-qemu:kvm`, `chmod 600`).

### Gotchas this VM has already caught (context for new failures)

- `bootstrap/08-dotfiles.sh` must run as the normal user, not root — it operates
  directly on `$HOME`. Only the apt-installing scripts self-elevate via `ensure_root`
  in `lib/root.sh`. Never wrap `bootstrap/run.sh` itself in `sudo`.
- System-wide (`--system`) flatpak installs need a polkit-authorized graphical
  session and fail silently over plain SSH. Bootstrap-managed flatpaks (e.g. Gradia)
  use `--user` scope for this reason.
- `chsh` requires interactive PAM auth; it fails non-interactively even with
  passwordless sudo unless run as root or already converged to the target shell.
- Ubuntu auto-creates `~/.config/user-dirs.dirs`/`user-dirs.locale` as real files on
  first login. Any new managed dotfile that could already exist on a fresh machine
  needs `backup_managed_file_conflict` handling in `08-dotfiles.sh`, or
  `mise bootstrap dotfiles apply` refuses to overwrite it.
- GNOME (50+) does not use `org.gnome.desktop.default-applications.terminal` for
  Ctrl+Alt+T — it shells out to `xdg-terminal-exec`, which reads
  `~/.config/xdg-terminals.list` (highest-priority user override). That's the file to
  manage for a default-terminal change, not a dconf/gsettings key.

## Adding New Tests

Edit `test/test-dotfiles.sh` and add new test cases following the pattern:

```bash
if <test-condition>; then
    pass "Description"
else
    fail "Description"
fi
```
