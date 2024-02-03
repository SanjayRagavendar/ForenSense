$dateTime= Get-Time -Format yyyy-mm-dd_HH-mm
$endpointUrl = "https://127.0.0.1:5000/api/report"   

New-Item -ItemType Directory -Path $evidenceDirectory -Force

$systemInfo = Get-WmiObject Win32_ComputerSystem
$osInfo = Get-WmiObject Win32_OperatingSystem
$diskInfo = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}

$systemInfo | Out-File "$evidenceDirectory\system_info.txt"
$osInfo | Out-File "$evidenceDirectory\os_info.txt"
$diskInfo | Out-File "$evidenceDirectory\disk_info.txt"

$rootDirectory = "C:\"
$files = Get-ChildItem -Path $rootDirectory -Recurse -File
foreach ($file in $files) {
    $file.Attributes = "ReadOnly"
    Write-Host "Set read-only attribute for $($file.FullName)"
}
#./exportReg.ps1
#./checksumCheck.ps1
@"
Forensic Investigation Report - Case $caseNumber

System Information:
$($systemInfo | Out-String)

Operating System Information:
$($osInfo | Out-String)

Disk Information:
$($diskInfo | Out-String)

Analysis Findings:
Add analysis findings here...

"@ | Out-File $reportFile

Write-Host "Forensic investigation completed. Report saved to: $reportFile"

Invoke-RestMethod -Uri $endpointUrl -Method Post -Body "file="$reportFile

Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Disable-NetAdapter -Confirm:$false
