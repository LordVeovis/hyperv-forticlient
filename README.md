# OpenfortiVPN Hardened

## Description

This is a PoC intended to show how to build a hardened VM on Hyper-V.
One use case, illustrated by this repository is to provide the user, on a non-trusted computer, a secured and restricted VPN connection.

## Features

* Disk is encrypted with LUKS, including the GRUB configuration, Linux kernel and initramfs (so FDE)
* GRUB configuration is protected, only the normal boot is available
* Root user is password protected
* tty1 is reconfigured to launch the VPN client
* Firewall configured to restrict the VPN:
  * allow only RDP on a specific network from the workstation to the VPN network
  * deny everything else, including traffic from the VPN network back to the workstation
* VM has SecureBoot enabled

Not implemented:

* SELinux or any other Linux security modules

## Build

On an elevated Powershell terminal:

```powershell
$luks = Read-Host -Prompt 'LUKS password'
build.ps1 -LuksPassword $luks
```

## Usage

* Start the VM
* Type the LUKS password
* Get the assign IP from the VM console
* Add the route on the host: `route add vpn_network mask vpn_mask ip_vm`
* Type your VPN password in the VM console
