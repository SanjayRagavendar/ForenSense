$dateTime= Get-Time -Format yyyy-mm-dd_HH-mm
$caseNumber = "Case_$dateTime"
$evidenceDirectory = "C:\ForensicEvidence\$caseNumber"
$forensicImageFile = "$evidenceDirectory\$caseNumber_forensic_image.dd"
$reportFile = "$evidenceDirectory\$caseNumber_forensic_report.txt"
$networkShare = "\\fileserver\forensic_storage"
$endpointUrl = "https://your-endpoint-url"   

New-Item -ItemType Directory -Path $evidenceDirectory -Force

$systemInfo = Get-WmiObject Win32_ComputerSystem
$osInfo = Get-WmiObject Win32_OperatingSystem
$diskInfo = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}

$systemInfo | Out-File "$evidenceDirectory\system_info.txt"
$osInfo | Out-File "$evidenceDirectory\os_info.txt"
$diskInfo | Out-File "$evidenceDirectory\disk_info.txt"

Write-Host "Creating forensic image..."

New-PSDrive -Name "ForensicStorage" -PSProvider FileSystem -Root $networkShare -Persist

Copy-Item -Path $forensicImageFile -Destination "ForensicStorage:\$caseNumber\" -Force

Remove-PSDrive -Name "ForensicStorage"

$rootDirectory = "C:\"
$files = Get-ChildItem -Path $rootDirectory -Recurse -File
foreach ($file in $files) {
    $file.Attributes = "ReadOnly"
    Write-Host "Set read-only attribute for $($file.FullName)"
}
./exportReg.ps1
./checksumCheck.ps1
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

Invoke-RestMethod -Uri $endpointUrl -Method Post -Body $reportFile

autopsy-cli ingest -p $imageFilePath -n $caseName -o $outputDirectory

Start-Sleep -Seconds 900

Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Disable-NetAdapter -Confirm:$false

