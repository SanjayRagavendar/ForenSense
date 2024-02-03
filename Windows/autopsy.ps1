$SourceDeviceOrFile = "C:\"
$Destination = "F:\"
$ImageName = "EvidenceImage"
$ImageFormat = "e01" 
$LogFile = "F:\log"

Write-Host "Creating forensic image using FTK Imager CLI..."
& "ftkimager_cli.exe" /e $SourceDeviceOrFile $Destination\$ImageName.$ImageFormat >> $LogFile

Write-Host "Analyzing the image using Autopsy CLI..."
& "autopsy_cli.exe" -import $Destination\$ImageName.$ImageFormat >> $LogFile

Write-Host "Forensic analysis complete. Logs saved to $LogFile"