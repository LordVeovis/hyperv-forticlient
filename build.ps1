[CmdletBinding()]
param (
    [switch]$Debug0,
    [string]$VmName = 'packer-fortress2'
)

packer init base-luks.pkr.hcl

$env:PKR_VAR_luks_pwd = [Guid]::NewGuid().ToString("B")
$env:PKR_VAR_grub_pwd = [Guid]::NewGuid().ToString("B")
$env:PKR_VAR_root_pwd = [Guid]::NewGuid().ToString("B")

packer validate base-luks.pkr.hcl

$vm = hyper-v\Get-VM $VmName -ErrorAction SilentlyContinue
if ($null -ne $vm) {
    Stop-VM $VmName -Force
    Remove-VM $VmName -Force
    Remove-Item .\output-vm\ -Recurse -Force
}

if ($Debug0) {
    $env:PKR_VAR_luks_pwd = 'proute'
    $env:PKR_VAR_grub_pwd = 'prouty'
    $env:PKR_VAR_root_pwd = 'prouto'
}

$env:PKR_VAR_vm_name = $VmName

packer build -on-error=ask -timestamp-ui .\base-luks.pkr.hcl

if ($LastExitCode -eq 0) {
    $vmGuid = Get-Item '.\output-vm\Virtual Machines\*.vmcx' `
        | Sort-Object LastWriteTime `
        | Select-Object -First 1 -ExpandProperty Name

    Import-VM -Path ".\output-vm\Virtual Machines\$vmGuid" -Register
    Start-VM $VmName
}