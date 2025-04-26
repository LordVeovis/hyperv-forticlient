[CmdletBinding()]
param (
    [switch]$DebugMode,
    [string]$LuksPassword,
    [string]$VmName = 'openfortivpn-hardened'
)

packer init openfortivpn-hardened.pkr.hcl

$env:PKR_VAR_luks_pwd = [Guid]::NewGuid().ToString("B")
$env:PKR_VAR_grub_pwd = [Guid]::NewGuid().ToString("B")
$env:PKR_VAR_root_pwd = [Guid]::NewGuid().ToString("B")

packer validate openfortivpn-hardened.pkr.hcl

$vm = hyper-v\Get-VM $VmName -ErrorAction SilentlyContinue
if ($null -ne $vm) {
    Stop-VM $VmName -Force
    Remove-VM $VmName -Force
    Remove-Item .\output-vm\ -Recurse -Force
}

if ($DebugMode) {
    $env:PKR_VAR_luks_pwd = 'proute'
    $env:PKR_VAR_grub_pwd = 'prouty'
    $env:PKR_VAR_root_pwd = 'prouto'
}

if ($null -ne $LuksPassword) {
    $env:PKR_VAR_luks_pwd = $LuksPassword
}

$env:PKR_VAR_vm_name = $VmName

packer build -on-error=ask -timestamp-ui openfortivpn-hardened.pkr.hcl

if ($LastExitCode -eq 0 -and $DebugMode) {
    $vmGuid = Get-Item '.\output-vm\Virtual Machines\*.vmcx' `
        | Sort-Object LastWriteTime `
        | Select-Object -First 1 -ExpandProperty Name

    $vm = Import-VM -Path ".\output-vm\Virtual Machines\$vmGuid" -Register
    $vm | Start-VM
}