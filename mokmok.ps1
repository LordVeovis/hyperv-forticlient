$vmName = 'packer-fortress5'

$vm = Get-CimInstance -Namespace root\virtualization\v2 -ClassName Msvm_ComputerSystem -Filter "ElementName='$vmName'"
$kb = $vm | Get-CimAssociatedInstance -ResultClassName Msvm_Keyboard
# press any key to enter mok mgmt
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x28}
Start-Sleep 1
# go to enroll key
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x28}
Start-Sleep 1
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d}
Start-Sleep 1
# view or continue?
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x28}
Start-Sleep 1
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d}
Start-Sleep 1
# enroll key?
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x28}
Start-Sleep 1
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d}
Start-Sleep 1
# password
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x53}
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x44}
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x46}
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x47}
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x48}
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x4a}
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x4b}
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x4c}
Start-Sleep -Milliseconds 250
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d}
Start-Sleep -Milliseconds 250
# reboot?
$kb | Invoke-CimMethod -MethodName "TypeKey" -Arguments @{ keyCode = 0x0d}

Start-Sleep 5
Get-VM $vmName | Stop-VM