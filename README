# Description

This is a PoC intended to show how to build a hardened VM on Hyper-V.
One use case, illustrated by this repository is to provide the user, on a non-trusted computer, a secured and restricted VPN connection.

# Features

* Disk is encrypted with LUKS, including the GRUB configuration and Linux kernel (so FDE)
* GRUB configuration is locked, only the normal boot is available
* Root user is password protected
* tty1 is reconfigured to launch the VPN client
* Firewall configured to restrict the VPN:
    * allow only RDP on a specific network from the workstation to the VPN network
    * deny everything else, including traffic from the VPN network to the workstation

Not implemented:

* SecureBoot
* SeLinux

# Build

On an elevated prompt:

```powershell
$env:LUKS_PWD = Read-Host
$env:GRUB_PWD = Read-Host
$env:ROOT_PWD = Read-Host
$env:FORTI_USER = Read-Host
$env:FORTI_DNS = Read-Host

packer init base-luks.pkr.hcl
packer build base-luks.pkr.hcl
```

# Usage

* Start the VM
* Get the assign IP from the VM console
* Add the route on the host: `route add vpn_network mask vpn_mask ip_vm`
* Type your VPN password in the VM console