# ubuntu-desktop-cloud-image

Builds an Ubuntu Noble (24.04) desktop cloud image from the official server
cloud image using GitHub Actions.

## What it does
- Downloads `noble-server-cloudimg-amd64.img`
- Expands the disk to 8G
- Installs desktop and tools (`ubuntu-desktop`, `xrdp`, `vim`,
  `net-tools`, `nmap`, `snapd`)
- Installs GRUB and updates the boot config
- Compresses the result to `noble-desktop-cloudimg-amd64.img`
- Tags and publishes a GitHub Release on pushes to `main`

## Output
The workflow publishes a release artifact named
`noble-desktop-cloudimg-amd64.img`.

## Compatibility
The image can be used with QEMU and VirtualBox.

## Cloud-init
Cloud-init is used to configure the VM on first boot (users, SSH keys,
packages, hostname, and networking). This image expects a NoCloud seed
attached as a disk or CD-ROM.

## How to use cloud-init
1. Create `user-data` and `meta-data` files.
2. Build a seed image (from the `cloud-image-utils` package):
   `cloud-localds seed.iso user-data meta-data`
3. Attach `seed.iso` to the VM along with the main disk image.

Example `user-data`:
```yaml
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 REPLACE_WITH_YOUR_KEY
chpasswd:
  expire: false
```

Example `meta-data`:
```yaml
instance-id: ubuntu-desktop
local-hostname: ubuntu-desktop
```

QEMU example:
```sh
qemu-system-x86_64 \
  -m 4096 -smp 2 \
  -drive file=noble-desktop-cloudimg-amd64.img,format=qcow2,if=virtio \
  -drive file=seed.iso,format=raw,media=cdrom
```

VirtualBox:
Attach `noble-desktop-cloudimg-amd64.img` as the primary disk and
`seed.iso` as an optical drive, then boot the VM.
