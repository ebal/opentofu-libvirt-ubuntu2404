# Project: OpenTofu + libvirt (tf provider v0.9.1) — Ubuntu 24.04 LTS

This repository contains an OpenTofu deployment that boots Ubuntu 24.04 LTS cloud images on a libvirt/QEMU host using the `dmacvicar/libvirt` terraform provider v0.9.1. The reason of this project it to document the terraform-libvirt v0.v9+ provider which is a completely rewrite with a specific design principle: "Models the libvirt XML schemas directly instead of abstracting them, giving users full access to libvirt features."

## This repository is opinionated!
- SSH hardening, by default
- removes unnecessary packages and old kernels after upgrade
- installs some basic necessary packages
- provides an alternative user-data (cloud-init) template file (user-data-debug.yml) for troubleshooting.

## Watch the full demo example video

<!-- for MP4, link to it -->
![Watch the full demo example video](opentofu-libvirt-ubuntu2404.gif)

## Quick reference to key resources and files:

- OpenTu/Terraform providers & initialization: [provider.tf](provider.tf) (`random`, `tailscale`, `libvirt` provider)
- VM domain definition: [domain.tf](domain.tf) — main domain resource is [`libvirt_domain.example`](domain.tf).
- Cloud-init ISO & metadata: [cloudinit.tf](cloudinit.tf) — cloud-init disk resource is [`libvirt_cloudinit_disk.init`](cloudinit.tf).
- Base and derived QCOW2 volumes: [volume.tf](volume.tf) — key volumes include [`libvirt_volume.ubuntu_24_04_image`](volume.tf), based on a download copy of https://cloud-images.ubuntu.com/oracular/current/oracular-server-cloudimg-amd64.img (ubuntu 24.04.LTS)
- Outputs & wait logic: [output.tf](output.tf) — wait resource [`time_sleep.wait_for_dhcp`](output.tf) and output `network_interfaces` , for getting the VM IP from DHCP lease.
- Local configuration variables and rendered templates: [variables.tf](variables.tf) — local values and rendered `local.user_data` are defined here (`locals` block) [`locals`](variables.tf).
- Templates used by cloud-init:
  - [templates/user-data.yml](templates/user-data.yml)
  - [templates/sshd_config](templates/sshd_config)
  - [templates/netplan.yml](templates/netplan.yml)
  - [templates/cleanup.sh](templates/cleanup.sh)
- Helper scripts:
  - [autostart.sh](autostart.sh) — initialize + apply flow
  - [destroy.sh](destroy.sh) — destroy and cleanup artifacts

## Repository layout
- provider.tf
- domain.tf
- cloudinit.tf
- volume.tf
- variables.tf
- output.tf
- templates/
  - user-data.yml
  - user-data-debug.yml
  - sshd_config
  - netplan.yml
  - cleanup.sh
- autostart.sh
- destroy.sh
- LICENSE
- .gitignore

## Prerequisites
- libvirt, qemu/kvm installed and running on the host.
- A user with permission to manage libvirt domains or sudo access.
- OpenTofu/terraform (this repo uses "tofu" CLI in scripts). See [provider.tf](provider.tf) for required provider versions.
- Ensure the **default** libvirt network exists (or adjust [domain.tf](domain.tf) interfaces).
- Ensure the **default** pool volume/images exists.
- I use `Consul` via docker on my homelab to ensure OpenTofu/Terraform state is on a backend and not on the local directory. Modify or remove section **backend** in [provider.tf](provider.tf). See Appendix section.

## Quickstart — create the infrastructure
1. Edit configuration
   - Adjust values in [variables.tf](variables.tf) (hostname, gh_user, ssh_port, cloud_image path, sizes).
   - Verify image path referenced in [volume.tf](volume.tf) (local path or a public URL). The default image targets Ubuntu 24.04 LTS.
   - On my system the download copy of ubuntu 24.04.LTS is on the below path:
   `ls -l ../../images/ubuntu/noble-server-cloudimg-amd64.img`

2. Initialize and apply
   - Initialize providers and modules:
     - tofu init
   - Format & validate:
     - tofu fmt -recursive
     - tofu validate
   - Plan and apply:
     - tofu plan -out tofu.out
     - tofu apply -auto-approve tofu.out
   - The provided helper script [autostart.sh](autostart.sh) automates these steps.
   - To avoid conflict volume/images/iso in default volume pool, `random` plugin is used to generate hashed names in each autostart.

3. Verify
   - After apply completes, the deployment waits (~20s) for DHCP via [`time_sleep.wait_for_dhcp`](output.tf) and then queries interfaces.
   - Retrieve the assigned address:
     - tofu output network_interfaces
     - The `network_interfaces` output is produced by [output.tf](output.tf) querying [`libvirt_domain.example`](domain.tf).

## Post-deploy notes
- Cloud-init contents are rendered from [templates/user-data.yml](templates/user-data.yml) using locals in [variables.tf](variables.tf). The cloud-init ISO disk is [`libvirt_cloudinit_disk.init`](cloudinit.tf).
- SSH keys are imported using GitHub import id (configured via `gh_user` in [variables.tf](variables.tf)).
- A hardened sshd config is provided at [templates/sshd_config](templates/sshd_config).

## Destroy and Clean up
- Run the destroy helper:
  - ./destroy.sh
- Or Use terraform/tofu destroy:
  - tofu destroy -auto-approve
- The destroy script removes local artifacts like `tofu.out`, `.terraform*`, and `terraform.tfstate*` on success, providing a clean setup env for next autostart.

## Troubleshooting
- If domain fails to start:
  - Check libvirt logs and `virsh list --all`.
  - Confirm base image path in [volume.tf](volume.tf).
- If no IP appears:
  - Validate the libvirt "default" network is up.
  - Check DHCP leases and the `wait_for_ip` timeout in [domain.tf](domain.tf).
- For cloud-init issues:
  - Inspect the generated ISO path from [`libvirt_cloudinit_disk.init`](cloudinit.tf).
  - Review [templates/user-data.yml](templates/user-data.yml) and rendered `local.user_data` in [variables.tf](variables.tf).

## Security considerations
- The templates disable password auth and permit only imported SSH keys. Confirm `gh_user` in [variables.tf](variables.tf).
- The repo includes a LICENSE file: [LICENSE](LICENSE).

## Files referenced (open from this repo)
- [provider.tf](provider.tf) — providers and [`random_id.id`](provider.tf)
- [domain.tf](domain.tf) — [`libvirt_domain.example`](domain.tf)
- [cloudinit.tf](cloudinit.tf) — [`libvirt_cloudinit_disk.init`](cloudinit.tf)
- [volume.tf](volume.tf) — [`libvirt_volume.ubuntu_24_04_image`](volume.tf)
- [variables.tf](variables.tf) — `locals` / `local.user_data` (`locals` block) [`locals`](variables.tf)
- [output.tf](output.tf) — [`time_sleep.wait_for_dhcp`](output.tf) and outputs
- [templates/user-data.yml](templates/user-data.yml)
- [templates/sshd_config](templates/sshd_config)
- [templates/netplan.yml](templates/netplan.yml)
- [templates/cleanup.sh](templates/cleanup.sh)
- [autostart.sh](autostart.sh)
- [destroy.sh](destroy.sh)
- [LICENSE](LICENSE)
- [.gitignore](.gitignore)

That's it!

