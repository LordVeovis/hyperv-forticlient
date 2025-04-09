[CmdletBinding()]
param (
    [switch]$Debug0,
    [string]$VmName = 'packer-fortress2'
)

packer init base-luks.pkr.hcl
packer validate base-luks.pkr.hcl

$vm = Get-VM $VmName -ErrorAction SilentlyContinue
if ($null -ne $vm) {
    Stop-VM $VmName -Force
    Remove-VM $VmName -Force
    Remove-Item .\output-vm\ -Recurse -Force
}

$env:LUKS_PWD = 'Kelp-Lumpiness6-Fondling'
$env:GRUB_PWD = [Guid]::NewGuid().ToString()
$env:ROOT_PWD = [Guid]::NewGuid().ToString()
$env:FORTI_DNS = 'vpn.invalid.lan'
$env:FORTI_USER = 'itsamemario'

if ($Debug0) {
    $env:LUKS_PWD = 'proute'
    $env:GRUB_PWD = 'prouty'
    $env:ROOT_PWD = 'prouto'
}

packer build -timestamp-ui -var vm_name=$VmName .\base-luks.pkr.hcl

if ($LastExitCode -eq 0) {
$vmGuid = Get-Item '.\output-vm\Virtual Machines\*.vmcx' `
    | Sort-Object LastWriteTime `
    | Select-Object -First 1 -ExpandProperty Name

Import-VM -Path ".\output-vm\Virtual Machines\$vmGuid" -Register
Start-VM $VmName
}