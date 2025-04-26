param(
    [String]$VMName
)

$cimVM = Get-CimInstance -Namespace root\virtualization\v2 -ClassName Msvm_ComputerSystem -Filter "ElementName='$VMName'"
$kb = $cimVM | Get-CimAssociatedInstance -ResultClassName Msvm_Keyboard
# press any key to enter mok mgmt
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x28} | Out-Null
Start-Sleep 1
# go to enroll key menu
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x28} | Out-Null
Start-Sleep 1
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d} | Out-Null
Start-Sleep 1
# view or continue? select continue
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x28} | Out-Null
Start-Sleep 1
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d} | Out-Null
Start-Sleep 1
# enroll key? yes
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x28} | Out-Null
Start-Sleep 1
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d} | Out-Null
Start-Sleep 1
# type password set with mokutil
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x53} | Out-Null
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x44} | Out-Null
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x46} | Out-Null
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x47} | Out-Null
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x48} | Out-Null
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x4a} | Out-Null
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x4b} | Out-Null
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x4c} | Out-Null
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d} | Out-Null
Start-Sleep -Milliseconds 250
# reboot? yes
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d} | Out-Null

# wait for the os to be initialized
Start-Sleep 5
$vm = Get-VM $VMName
$vm | Stop-VM
$vm | Set-VMFirmware -EnableSecureBoot On