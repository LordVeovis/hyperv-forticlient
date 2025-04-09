[CmdletBinding()]
param (
    [switch]$Debug0
)

packer init base-luks.pkr.hcl
packer validate base-luks.pkr.hcl

$vm = Get-VM packer-fortress -ErrorAction SilentlyContinue
if ($null -ne $vm) {
    Stop-VM packer-fortress -Force
    Remove-VM packer-fortress -Force
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

packer build .\base-luks.pkr.hcl

$vmGuid = Get-Item '.\output-vm\Virtual Machines\*.vmcx' `
    | Sort-Object LastWriteTime `
    |Select-Object -First 1 -ExpandProperty Name

Import-VM -Path ".\output-vm\Virtual Machines\$vmGuid" -Register
